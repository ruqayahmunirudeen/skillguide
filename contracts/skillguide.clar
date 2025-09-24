(define-map users principal
  { role: (string-ascii 16), profile-uri: (string-utf8 256), stake: uint, trust-score: uint })

(define-map jobs uint
  { client: principal, freelancer: principal, milestones: (list 10 uint), status: (string-ascii 16), paid: uint })

(define-map submissions (tuple (job-id uint) (ms-id uint)) (tuple (uri (string-utf8 256)) (status (string-ascii 16))))
(define-map ai-scores (tuple (job-id uint)) uint)

(define-map disputes (tuple (job-id uint)) 
  { jurors: (list 7 principal), votes: (list 7 bool), resolved: bool })

(define-map rep-nft principal {score: uint, wins: uint, fails: uint, disputes: uint})

(define-map freelancer-auctions principal {min-bid: uint, top-bidder: principal, amount: uint})

(define-map dao-proposals uint { proposer: principal, title: (string-utf8 100), votes-for: uint, votes-against: uint, executed: bool })

(define-map referrals principal (list 10 principal))
(define-map subscriptions principal {tier: (string-ascii 16), expiry: uint})

(define-map challenges uint {
  creator: principal,
  topic: (string-ascii 32),
  title: (string-utf8 100),
  reward: uint,
  approved: bool,
  active: bool
})

(define-map submissions-skill (tuple (challenge-id uint) (submitter principal))
  { link: (string-utf8 256), reviewed: bool, passed: bool })

(define-map skill-nfts principal (list 100 (string-utf8 100)))
(define-map curator-stakes principal uint)
(define-map reputation principal uint)

(define-constant platform-fee-rate u5)
(define-constant slashing-penalty u10)

;; User Registration and Staking
(define-data-var user-counter uint u0)
(define-public (register (role (string-ascii 16)) (profile-uri (string-utf8 256)))
  (begin
    (map-insert users tx-sender {role: role, profile-uri: profile-uri, stake: u0, trust-score: u50})
    (var-set user-counter (+ (var-get user-counter) u1))
    (ok true)))

(define-public (stake-tokens (amount uint))
    (let (
        (transfer-ok (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (current (default-to {role: "                ", profile-uri: u"", stake: u0, trust-score: u0} (map-get? users tx-sender)))
       )
      (map-set users tx-sender {role: (get role current), profile-uri: (get profile-uri current), stake: (+ (get stake current) amount), trust-score: (get trust-score current)})
      (ok true)
    )
  )

;; Job Management with Platform Fee
(define-data-var job-counter uint u0)
(define-public (create-job (freelancer principal) (milestones (list 10 uint)) (total uint))
  (let ((job-id (var-get job-counter))
        (fee (/ (* total platform-fee-rate) u100))
        (net-amount (- total fee)))
    (let ((transfer-result (stx-transfer? total tx-sender (as-contract tx-sender))))
      (match transfer-result
        ok-result
          (begin
            (map-insert jobs job-id {client: tx-sender, freelancer: freelancer, milestones: milestones, status: "active", paid: net-amount})
            (var-set job-counter (+ job-id u1))
            (ok job-id))
        err-code (err err-code)))))

;; Milestone Submission & AI Grading
(define-public (submit-milestone (job-id uint) (ms-id uint) (uri (string-utf8 256)))
  (begin
    (map-set submissions {job-id: job-id, ms-id: ms-id} {uri: uri, status: "submitted"})
    (ok true)))

(define-public (oracle-grade (job-id uint) (ms-id uint) (score uint))
  (begin
    ;; TODO: Set a valid principal for the oracle, e.g. (is-eq tx-sender 'STB...)
    ;; (asserts! (is-eq tx-sender 'ST2J8EVYHP4N9Y6K6X2K0Q8QYQK9ZQZQZQZQZQ) (err u500))
    (ok true)))

;; Disputes & DAO Jury
(define-public (raise-dispute (job-id uint) (ms-id uint))
  (begin
    (map-set disputes {job-id: job-id} {jurors: (list), votes: (list), resolved: false})
    (ok true)))

(define-public (vote-dispute (job-id uint) (ms-id uint) (decision bool))
  (let ((d (map-get? disputes {job-id: job-id})))
    (asserts! (is-some d) (err u404))
    (ok true)))

;; Slashing Function
(define-public (slash-user (user principal))
  (let ((u (map-get? users user)))
    (match u u-val
      (begin
        (let ((stake (get stake u-val)))
          (if (>= stake slashing-penalty)
            (map-set users user (merge u-val {stake: (- stake slashing-penalty)}))
            (map-set users user (merge u-val {stake: u0}))))
        (ok true))
      (err u404))))

;; Reputation NFT and DID
(define-public (update-reputation (user principal) (delta int))
  (let ((u (default-to {role: "                ", profile-uri: u"", stake: u0, trust-score: u0} (map-get? users user)))
        (r (default-to {score: u50, wins: u0, fails: u0, disputes: u0} (map-get? rep-nft user))))
    (map-set rep-nft user 
      {score: (let ((new-score (+ (get trust-score u) (/ (get score r) u2))))
                (if (> new-score u0) new-score u0)),
       wins: (get wins r),
       fails: (get fails r),
       disputes: (get disputes r)})
    (ok true)))

(define-read-only (get-did-score (user principal))
  (let (
        (u (default-to {role: "                ", profile-uri: u"", stake: u0, trust-score: u0} (map-get? users user)))
        (r (default-to {score: u50, wins: u0, fails: u0, disputes: u0} (map-get? rep-nft user)))
       )
    (let ((score (+ (get trust-score u) (/ (get score r) u2))))
      (ok (if (> score u100) u100 score)))))

;; Freelancer Auction
(define-public (start-auction (min-bid uint))
  (begin
    (map-set freelancer-auctions tx-sender {min-bid: min-bid, top-bidder: tx-sender, amount: u0})
    (ok true)))



