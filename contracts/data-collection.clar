;; Data Collection Contract
;; Manages gathering of required information

(define-map data-submissions
  {
    entity-id: (string-utf8 36),
    requirement-id: (string-utf8 36),
    submission-id: (string-utf8 36)
  }
  {
    data-hash: (buff 32), ;; SHA-256 hash of the submitted data
    metadata: (string-utf8 500),
    timestamp: uint,
    submitter: principal
  }
)

(define-map data-fields
  {
    requirement-id: (string-utf8 36),
    field-id: (string-utf8 36)
  }
  {
    name: (string-utf8 100),
    description: (string-utf8 200),
    field-type: (string-utf8 50), ;; "text", "number", "date", "boolean", etc.
    is-required: bool
  }
)

(define-read-only (get-submission
    (entity-id (string-utf8 36))
    (requirement-id (string-utf8 36))
    (submission-id (string-utf8 36))
  )
  (map-get? data-submissions {
    entity-id: entity-id,
    requirement-id: requirement-id,
    submission-id: submission-id
  })
)

(define-read-only (get-field (requirement-id (string-utf8 36)) (field-id (string-utf8 36)))
  (map-get? data-fields { requirement-id: requirement-id, field-id: field-id })
)

(define-public (add-field
    (requirement-id (string-utf8 36))
    (field-id (string-utf8 36))
    (name (string-utf8 100))
    (description (string-utf8 200))
    (field-type (string-utf8 50))
    (is-required bool)
  )
  (let ((caller tx-sender))
    ;; Verify caller is admin (could be imported from another contract)
    (asserts! (not (is-some (get-field requirement-id field-id))) (err u1)) ;; Field already exists

    (ok (map-set data-fields
      { requirement-id: requirement-id, field-id: field-id }
      {
        name: name,
        description: description,
        field-type: field-type,
        is-required: is-required
      }
    ))
  )
)

(define-public (submit-data
    (entity-id (string-utf8 36))
    (requirement-id (string-utf8 36))
    (submission-id (string-utf8 36))
    (data-hash (buff 32))
    (metadata (string-utf8 500))
  )
  (let ((caller tx-sender))
    ;; Verify entity is allowed to submit (could check entity-verification contract)
    (asserts! (not (is-some (get-submission entity-id requirement-id submission-id))) (err u1)) ;; Submission already exists

    (ok (map-set data-submissions
      {
        entity-id: entity-id,
        requirement-id: requirement-id,
        submission-id: submission-id
      }
      {
        data-hash: data-hash,
        metadata: metadata,
        timestamp: block-height,
        submitter: caller
      }
    ))
  )
)

(define-public (update-submission
    (entity-id (string-utf8 36))
    (requirement-id (string-utf8 36))
    (submission-id (string-utf8 36))
    (data-hash (buff 32))
    (metadata (string-utf8 500))
  )
  (let ((caller tx-sender)
        (existing-submission (get-submission entity-id requirement-id submission-id)))
    (asserts! (is-some existing-submission) (err u404)) ;; Submission not found
    (asserts! (is-eq caller (get submitter (unwrap-panic existing-submission))) (err u403)) ;; Only original submitter can update

    (ok (map-set data-submissions
      {
        entity-id: entity-id,
        requirement-id: requirement-id,
        submission-id: submission-id
      }
      {
        data-hash: data-hash,
        metadata: metadata,
        timestamp: block-height,
        submitter: caller
      }
    ))
  )
)
