;; Submission Verification Contract
;; Records timely filing of reports

(define-data-var admin principal tx-sender)

;; Status: 0 = pending, 1 = verified, 2 = rejected, 3 = expired
(define-map verifications
  {
    entity-id: (string-utf8 36),
    requirement-id: (string-utf8 36),
    submission-id: (string-utf8 36)
  }
  {
    status: uint,
    verifier: (optional principal),
    verification-date: (optional uint),
    due-date: uint,
    comments: (string-utf8 200)
  }
)

(define-read-only (get-verification
    (entity-id (string-utf8 36))
    (requirement-id (string-utf8 36))
    (submission-id (string-utf8 36))
  )
  (map-get? verifications {
    entity-id: entity-id,
    requirement-id: requirement-id,
    submission-id: submission-id
  })
)

(define-public (register-submission
    (entity-id (string-utf8 36))
    (requirement-id (string-utf8 36))
    (submission-id (string-utf8 36))
    (due-date uint)
    (comments (string-utf8 200))
  )
  (let ((caller tx-sender))
    ;; Could verify entity and requirement exist in other contracts
    (asserts! (not (is-some (get-verification entity-id requirement-id submission-id))) (err u1)) ;; Verification already exists

    (ok (map-set verifications
      {
        entity-id: entity-id,
        requirement-id: requirement-id,
        submission-id: submission-id
      }
      {
        status: u0, ;; Pending
        verifier: none,
        verification-date: none,
        due-date: due-date,
        comments: comments
      }
    ))
  )
)

(define-public (verify-submission
    (entity-id (string-utf8 36))
    (requirement-id (string-utf8 36))
    (submission-id (string-utf8 36))
    (comments (string-utf8 200))
  )
  (let ((caller tx-sender)
        (existing-verification (get-verification entity-id requirement-id submission-id)))
    (asserts! (is-eq caller (var-get admin)) (err u403)) ;; Only admin can verify
    (asserts! (is-some existing-verification) (err u404)) ;; Verification not found

    (ok (map-set verifications
      {
        entity-id: entity-id,
        requirement-id: requirement-id,
        submission-id: submission-id
      }
      (merge (unwrap-panic existing-verification)
        {
          status: u1, ;; Verified
          verifier: (some caller),
          verification-date: (some block-height),
          comments: comments
        }
      )
    ))
  )
)

(define-public (reject-submission
    (entity-id (string-utf8 36))
    (requirement-id (string-utf8 36))
    (submission-id (string-utf8 36))
    (comments (string-utf8 200))
  )
  (let ((caller tx-sender)
        (existing-verification (get-verification entity-id requirement-id submission-id)))
    (asserts! (is-eq caller (var-get admin)) (err u403)) ;; Only admin can reject
    (asserts! (is-some existing-verification) (err u404)) ;; Verification not found

    (ok (map-set verifications
      {
        entity-id: entity-id,
        requirement-id: requirement-id,
        submission-id: submission-id
      }
      (merge (unwrap-panic existing-verification)
        {
          status: u2, ;; Rejected
          verifier: (some caller),
          verification-date: (some block-height),
          comments: comments
        }
      )
    ))
  )
)

(define-public (mark-expired
    (entity-id (string-utf8 36))
    (requirement-id (string-utf8 36))
    (submission-id (string-utf8 36))
  )
  (let ((caller tx-sender)
        (existing-verification (get-verification entity-id requirement-id submission-id)))
    (asserts! (is-eq caller (var-get admin)) (err u403)) ;; Only admin can mark expired
    (asserts! (is-some existing-verification) (err u404)) ;; Verification not found
    (asserts! (< (get due-date (unwrap-panic existing-verification)) block-height) (err u400)) ;; Not yet expired

    (ok (map-set verifications
      {
        entity-id: entity-id,
        requirement-id: requirement-id,
        submission-id: submission-id
      }
      (merge (unwrap-panic existing-verification)
        {
          status: u3 ;; Expired
        }
      )
    ))
  )
)
