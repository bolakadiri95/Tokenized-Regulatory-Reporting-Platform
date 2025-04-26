;; Requirement Tracking Contract
;; Records applicable compliance obligations

(define-data-var admin principal tx-sender)

;; Requirement types: 0 = report, 1 = disclosure, 2 = certification, 3 = other
(define-map requirements
  { requirement-id: (string-utf8 36) }
  {
    title: (string-utf8 100),
    description: (string-utf8 500),
    type: uint,
    frequency: (string-utf8 50), ;; "quarterly", "annual", etc.
    jurisdiction: (string-utf8 50),
    authority: (string-utf8 100),
    created-at: uint
  }
)

;; Maps entities to their applicable requirements
(define-map entity-requirements
  {
    entity-id: (string-utf8 36),
    requirement-id: (string-utf8 36)
  }
  {
    applicable-from: uint,
    applicable-until: (optional uint),
    notes: (string-utf8 200)
  }
)

(define-read-only (get-requirement (requirement-id (string-utf8 36)))
  (map-get? requirements { requirement-id: requirement-id })
)

(define-read-only (get-entity-requirement (entity-id (string-utf8 36)) (requirement-id (string-utf8 36)))
  (map-get? entity-requirements { entity-id: entity-id, requirement-id: requirement-id })
)

(define-public (add-requirement
    (requirement-id (string-utf8 36))
    (title (string-utf8 100))
    (description (string-utf8 500))
    (type uint)
    (frequency (string-utf8 50))
    (jurisdiction (string-utf8 50))
    (authority (string-utf8 100))
  )
  (let ((caller tx-sender))
    (asserts! (is-eq caller (var-get admin)) (err u403)) ;; Only admin can add requirements
    (asserts! (not (is-some (get-requirement requirement-id))) (err u1)) ;; Requirement ID already exists

    (ok (map-set requirements
      { requirement-id: requirement-id }
      {
        title: title,
        description: description,
        type: type,
        frequency: frequency,
        jurisdiction: jurisdiction,
        authority: authority,
        created-at: block-height
      }
    ))
  )
)

(define-public (assign-requirement
    (entity-id (string-utf8 36))
    (requirement-id (string-utf8 36))
    (notes (string-utf8 200))
  )
  (let ((caller tx-sender))
    (asserts! (is-eq caller (var-get admin)) (err u403)) ;; Only admin can assign requirements
    (asserts! (is-some (get-requirement requirement-id)) (err u404)) ;; Requirement not found

    (ok (map-set entity-requirements
      { entity-id: entity-id, requirement-id: requirement-id }
      {
        applicable-from: block-height,
        applicable-until: none,
        notes: notes
      }
    ))
  )
)

(define-public (remove-requirement
    (entity-id (string-utf8 36))
    (requirement-id (string-utf8 36))
  )
  (let ((caller tx-sender)
        (current-assignment (get-entity-requirement entity-id requirement-id)))
    (asserts! (is-eq caller (var-get admin)) (err u403)) ;; Only admin can remove requirements
    (asserts! (is-some current-assignment) (err u404)) ;; Assignment not found

    (ok (map-set entity-requirements
      { entity-id: entity-id, requirement-id: requirement-id }
      (merge (unwrap-panic current-assignment)
        {
          applicable-until: (some block-height)
        }
      )
    ))
  )
)
