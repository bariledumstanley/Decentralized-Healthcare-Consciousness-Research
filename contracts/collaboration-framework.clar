;; Collaboration Framework Contract
;; Facilitates consciousness research cooperation

(define-constant err-unauthorized (err u500))
(define-constant err-not-found (err u501))
(define-constant err-already-member (err u502))

;; Collaboration structure
(define-map collaborations
  { collaboration-id: uint }
  {
    name: (string-ascii 100),
    lead-researcher: principal,
    description: (string-ascii 300),
    creation-date: uint,
    status: (string-ascii 20)
  }
)

(define-map collaboration-members
  { collaboration-id: uint, member: principal }
  { join-date: uint, role: (string-ascii 50) }
)

(define-data-var next-collaboration-id uint u1)

;; Create new collaboration
(define-public (create-collaboration
  (name (string-ascii 100))
  (description (string-ascii 300)))
  (let ((collaboration-id (var-get next-collaboration-id)))
    (map-set collaborations
      { collaboration-id: collaboration-id }
      {
        name: name,
        lead-researcher: tx-sender,
        description: description,
        creation-date: block-height,
        status: "active"
      }
    )
    (map-set collaboration-members
      { collaboration-id: collaboration-id, member: tx-sender }
      { join-date: block-height, role: "lead" }
    )
    (var-set next-collaboration-id (+ collaboration-id u1))
    (ok collaboration-id)
  )
)

;; Join collaboration
(define-public (join-collaboration (collaboration-id uint) (role (string-ascii 50)))
  (let ((collaboration (unwrap! (map-get? collaborations { collaboration-id: collaboration-id }) err-not-found)))
    (asserts! (is-none (map-get? collaboration-members { collaboration-id: collaboration-id, member: tx-sender })) err-already-member)
    (map-set collaboration-members
      { collaboration-id: collaboration-id, member: tx-sender }
      { join-date: block-height, role: role }
    )
    (ok true)
  )
)

;; Get collaboration details
(define-read-only (get-collaboration (collaboration-id uint))
  (map-get? collaborations { collaboration-id: collaboration-id })
)

;; Check if member of collaboration
(define-read-only (is-collaboration-member (collaboration-id uint) (member principal))
  (is-some (map-get? collaboration-members { collaboration-id: collaboration-id, member: member }))
)

;; Share research findings
(define-public (share-findings (collaboration-id uint) (findings-hash (buff 32)))
  (let ((collaboration (unwrap! (map-get? collaborations { collaboration-id: collaboration-id }) err-not-found)))
    (asserts! (is-some (map-get? collaboration-members { collaboration-id: collaboration-id, member: tx-sender })) err-unauthorized)
    ;; In full implementation, would store findings reference
    (ok true)
  )
)
