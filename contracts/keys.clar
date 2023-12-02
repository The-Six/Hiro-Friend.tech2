;; Defining Key Balances and Supply
(define-map keysBalance { subject: principal, holder: principal } uint)
(define-map keysSupply { subject: principal } uint)

;; Calculating Key Prices
(define-read-only (get-price (supply uint) (amount uint))
  (let
    (
      (base-price u10)
      (price-change-factor u100)
      (adjusted-supply (+ supply amount))
    )
    (+ base-price (* amount (/ (* adjusted-supply adjusted-supply) price-change-factor)))
  )
)

;; Creating buying keys
(define-public (buy-keys (subject principal) (amount uint))
  (let
    (
      (supply (default-to u0 (map-get? keysSupply { subject: subject })))
      (price (get-price supply amount))
    )
    (if (or (> supply u0) (is-eq tx-sender subject))
      (begin
        (match (stx-transfer? price tx-sender (as-contract tx-sender))
          success
          (begin
            (map-set keysBalance { subject: subject, holder: tx-sender }
              (+ (default-to u0 (map-get? keysBalance { subject: subject, holder: tx-sender })) amount)
            )
            (map-set keysSupply { subject: subject } (+ supply amount))
            (ok true)
          )
          error
          (err u2)
        )
      )
      (err u1)
    )
  )
)

;; Creating selling keys
(define-public (sell-keys (subject principal) (amount uint))
  (let
    (
      (balance (default-to u0 (map-get? keysBalance { subject: subject, holder: tx-sender })))
      (supply (default-to u0 (map-get? keysSupply { subject: subject })))
      (price (get-price supply amount))
      (recipient tx-sender)
    )
    (if (and (>= balance amount) (or (> supply u0) (is-eq tx-sender subject)))
      (begin
        (match (as-contract (stx-transfer? price tx-sender recipient))
          success
          (begin
            (map-set keysBalance { subject: subject, holder: tx-sender } (- balance amount))
            (map-set keysSupply { subject: subject } (- supply amount))
            (ok true)
          )
          error
          (err u2)
        )
      )
      (err u1)
    )
  )
)

;; Verifying Keyholders
(define-read-only (is-keyholder (subject principal) (holder principal))
  (>= (default-to u0 (map-get? keysBalance { subject: subject, holder: holder })) u1)
)

;; Starter challenge: Balance and Supply Query Functions
;; Balance Query Function
(define-read-only (get-keys-balance (subject principal) (holder principal))
  ;; Return the keysBalance for the given subject and holder
  (map-get? keysBalance { subject: subject, holder: holder })
)

;; Supply Query Function
(define-read-only (get-keys-supply (subject principal))
  ;; Return the keysSupply for the given subject
  (map-get? keysSupply { subject: subject })
)

;; title: keys
;; version:
;; summary:
;; description:

;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;;

;; data maps

;;

;; public functions
;;

;; read only functions
;;

;; private functions
;;

