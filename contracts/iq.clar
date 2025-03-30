;; Smart Contract on Intellectual Property Protection - IntellectGuard
;; Define error codes
(define-constant ERR-NOT-AUTHORIZED (err u1000))
(define-constant ERR-INVALID-HASH-LENGTH (err u1001))
(define-constant ERR-HASH-ALL-ZEROS (err u1002))
(define-constant ERR-HASH-ALREADY-REGISTERED (err u1003))
(define-constant ERR-IP-NOT-FOUND (err u1004))
(define-constant ERR-INVALID-IP-ID (err u1005))
(define-constant ERR-IP-ID-OUT-OF-RANGE (err u1006))

;; Define the contract
(define-data-var intellect-guard-owner principal tx-sender)

;; Define a map to store IP registrations
(define-map intellect-guard-registrations
  { intellect-guard-id: uint }
  { owner: principal, timestamp: uint, hash: (buff 32) }
)

;; Define a map to track registered hashes
(define-map intellect-guard-hashes
  { hash: (buff 32) }
  { intellect-guard-id: uint }
)

;; Define a counter for IP IDs
(define-data-var intellect-guard-counter uint u0)

;; Function to register new IP
(define-public (register-intellect-guard (intellect-guard-hash (buff 32)))
  (let
    (
      (new-id (+ (var-get intellect-guard-counter) u1))
    )
    ;; Perform input validation
    (asserts! (is-eq (len intellect-guard-hash) u32) ERR-INVALID-HASH-LENGTH)
    (asserts! (not (is-eq intellect-guard-hash 0x0000000000000000000000000000000000000000000000000000000000000000)) ERR-HASH-ALL-ZEROS)
    (asserts! (is-none (map-get? intellect-guard-hashes { hash: intellect-guard-hash })) ERR-HASH-ALREADY-REGISTERED)
    
    ;; Register the IP
    (map-set intellect-guard-registrations
      { intellect-guard-id: new-id }
      { owner: tx-sender, timestamp: block-height, hash: intellect-guard-hash }
    )
    ;; Track the registered hash
    (map-set intellect-guard-hashes
      { hash: intellect-guard-hash }
      { intellect-guard-id: new-id }
    )
    (var-set intellect-guard-counter new-id)
    (ok new-id)
  )
)

