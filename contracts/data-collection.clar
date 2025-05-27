;; Data Collection Contract
;; Manages consciousness research data with privacy protection

(define-constant err-unauthorized (err u300))
(define-constant err-not-found (err u301))
(define-constant err-invalid-data (err u302))

;; Data entry structure
(define-map data-entries
  { entry-id: uint }
  {
    protocol-id: uint,
    researcher: principal,
    data-hash: (buff 32),
    timestamp: uint,
    subject-count: uint,
    data-type: (string-ascii 50),
    privacy-level: (string-ascii 20)
  }
)

(define-data-var next-entry-id uint u1)

;; Submit research data (hash only for privacy)
(define-public (submit-data
  (protocol-id uint)
  (data-hash (buff 32))
  (subject-count uint)
  (data-type (string-ascii 50))
  (privacy-level (string-ascii 20)))
  (let ((entry-id (var-get next-entry-id)))
    (map-set data-entries
      { entry-id: entry-id }
      {
        protocol-id: protocol-id,
        researcher: tx-sender,
        data-hash: data-hash,
        timestamp: block-height,
        subject-count: subject-count,
        data-type: data-type,
        privacy-level: privacy-level
      }
    )
    (var-set next-entry-id (+ entry-id u1))
    (ok entry-id)
  )
)

;; Get data entry
(define-read-only (get-data-entry (entry-id uint))
  (map-get? data-entries { entry-id: entry-id })
)

;; Get data entries by protocol
(define-read-only (get-protocol-data-count (protocol-id uint))
  ;; Simplified - would need iteration in full implementation
  u0
)

;; Verify data integrity
(define-read-only (verify-data-hash (entry-id uint) (provided-hash (buff 32)))
  (match (map-get? data-entries { entry-id: entry-id })
    entry (is-eq (get data-hash entry) provided-hash)
    false
  )
)
