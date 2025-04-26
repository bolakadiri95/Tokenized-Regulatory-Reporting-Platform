;; Entity Verification Contract
;; Validates regulated businesses and their status

(define-data-var admin principal tx-sender)

;; Entity status: 0 = unverified, 1 = verified, 2 = suspended
(define-map entities
  { entity-id: (string-utf8 36) }
  {
    principal: principal,
    name: (string-utf8 100),
    registration-number: (string-utf8 50),
    jurisdiction: (string-utf8 50),
    status: uint,
    verification-date: uint
  }
)

(define-read-only (get-entity (entity-id (string-utf8 36)))
  (map-get? entities { entity-id: entity-id })
)

(define-read-only (is-verified (entity-id (string-utf8 36)))
  (let ((entity (get-entity entity-id)))
    (if (is-some entity)
      (is-eq (get status (unwrap-panic entity)) u1)
      false
    )
  )
)

(define-public (register-entity
    (entity-id (string-utf8 36))
    (name (string-utf8 100))
    (registration-number (string-utf8 50))
    (jurisdiction (string-utf8 50))
  )
  (let ((caller tx-sender))
    (asserts! (not (is-some (get-entity entity-id))) (err u1)) ;; Entity ID already exists
    (ok (map-set entities
      { entity-id: entity-id }
      {
        principal: caller,
        name: name,
        registration-number: registration-number,
        jurisdiction: jurisdiction,
        status: u0, ;; Unverified by default
        verification-date: u0
      }
    ))
  )
)

(define-public (verify-entity (entity-id (string-utf8 36)))
  (let ((caller tx-sender))
    (asserts! (is-eq caller (var-get admin)) (err u403)) ;; Only admin can verify
    (asserts! (is-some (get-entity entity-id)) (err u404)) ;; Entity not found

    (ok (map-set entities
      { entity-id: entity-id }
      (merge (unwrap-panic (get-entity entity-id))
        {
          status: u1,
          verification-date: block-height
        }
      )
    ))
  )
)

(define-public (suspend-entity (entity-id (string-utf8 36)))
  (let ((caller tx-sender))
    (asserts! (is-eq caller (var-get admin)) (err u403)) ;; Only admin can suspend
    (asserts! (is-some (get-entity entity-id)) (err u404)) ;; Entity not found

    (ok (map-set entities
      { entity-id: entity-id }
      (merge (unwrap-panic (get-entity entity-id))
        {
          status: u2
        }
      )
    ))
  )
)

(define-public (transfer-admin (new-admin principal))
  (let ((caller tx-sender))
    (asserts! (is-eq caller (var-get admin)) (err u403)) ;; Only current admin can transfer
    (ok (var-set admin new-admin))
  )
)
