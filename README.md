# SkillGuide - Decentralized Freelancing Platform

A decentralized freelancing platform built on Stacks blockchain that enables secure, transparent, and efficient collaboration between clients and freelancers.

## Features

- **User Registration & Staking**
  - Role-based user system
  - STX token staking mechanism
  - Profile management with URI storage

- **Job Management**
  - Milestone-based project tracking
  - Platform fee structure (5%)
  - Secure payment handling

- **Reputation System**
  - NFT-based reputation tracking
  - Trust score calculation
  - DID integration for identity verification

- **Dispute Resolution**
  - DAO-based jury system
  - Democratic voting mechanism
  - Slashing penalties for bad actors

- **Additional Features**
  - Freelancer auction system
  - AI-powered submission grading
  - Challenge-based skill verification
  - Referral system
  - Subscription tiers

## Smart Contract Functions

### Core Functions

```clarity
(register (role) (profile-uri))
(stake-tokens (amount))
(create-job (freelancer) (milestones) (total))
(submit-milestone (job-id) (ms-id) (uri))
(raise-dispute (job-id) (ms-id))
```

## Installation

1. Clone the repository
2. Install Clarinet
3. Deploy using Clarinet console

## Testing

Run tests using Clarinet:

```bash
clarinet test
```

## Contributing

1. Fork the repository
2. Create feature branch
3. Submit pull request

- Default trust score: 50

For security issues, please email: security@skillguide.com
