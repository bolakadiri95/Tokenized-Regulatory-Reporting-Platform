;; Audit Trail Contract
;; Maintains immutable record of compliance activities

(define-map audit-events
  { event-id: (string-utf8 36) }
  {
    entity-id: (string-utf8 36),
    event-type: (string-utf8 50), ;; "entity-verification", "requirement-assignment", "data-submission", etc.
    related-id: (string-utf8 36), ;; ID of the related entity in the respective contract
    data-hash: (buff 32), ;; Hash of the event data
    timestamp: uint,
    actor: principal
  }
)

(define-read-only (get-audit-event (event-id (string-utf8 36)))
  (map-get? audit-events { event-id: event-id })
)

(define-public (record-audit-event
    (event-id (string-utf8 36))
    (entity-id (string-utf8 36))
    (event-type (string-utf8 50))
    (related-id (string-utf8 36))
    (data-hash (buff 32))
  )
  (let ((caller tx-sender))
    (asserts! (not (is-some (get-audit-event event-id))) (err u1)) ;; Event ID already exists

    (ok (map-set audit-events
      { event-id: event-id }
      {
        entity-id: entity-id,
        event-type: event-type,
        related-id: related-id,
        data-hash: data-hash,
        timestamp: block-height,
        actor: caller
      }
    ))
  )
)

;; Function to verify if an audit event exists and matches expected data
(define-read-only (verify-audit-event
    (event-id (string-utf8 36))
    (expected-hash (buff 32))
  )
  (let ((event (get-audit-event event-id)))
    (if (is-some event)
      (is-eq (get data-hash (unwrap-panic event)) expected-hash)
      false
    )
  )
)

;; Function to get all audit events for a specific entity (would need pagination in practice)
;; Note: In Clarity, we can't return arrays, so this is a simplified example
(define-read-only (get-entity-event-count (entity-id (string-utf8 36)))
  ;; In a real implementation, we would need to track this separately
  ;; This is a placeholder for demonstration
  u0
)
