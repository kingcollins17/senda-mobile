# Wallet-First UX

## Core Product Principle

The user's wallet is the source of their crypto balance.

Therefore:

**No wallet connected → no balance.**

The application should make this obvious without making the user feel blocked.

The first meaningful action is:

> Connect your wallet.

Supported networks:

- Ethereum
- Solana
- Polygon

The user should not have to understand the difference between these networks unless they need to.

---

# 1. First Launch

After the splash screen, show a minimal welcome screen.

```text
┌──────────────────────────────┐
│                              │
│                              │
│                              │
│          [LOGO]              │
│                              │
│     Your crypto.             │
│     Your everyday life.      │
│                              │
│  Pay for things using the    │
│  crypto you already own.     │
│                              │
│                              │
│  ┌────────────────────────┐  │
│  │     Connect wallet     │  │
│  └────────────────────────┘  │
│                              │
│       I'll do this later     │
│                              │
└──────────────────────────────┘
```

The primary CTA is **Connect wallet**.

"Do this later" can exist, but the user should understand that they won't see their crypto balance until a wallet is connected.

---

# 2. Wallet Connection Screen

When the user taps Connect wallet:

```text
Connect your wallet

Choose a wallet to get started.

┌──────────────────────────────┐
│ 🦊  MetaMask                 │
│     Ethereum · Polygon      ›│
└──────────────────────────────┘

┌──────────────────────────────┐
│ ◇   Phantom                  │
│     Solana · Ethereum       ›│
└──────────────────────────────┘

┌──────────────────────────────┐
│ ◎   WalletConnect            │
│     Connect another wallet  ›│
└──────────────────────────────┘
```

Do not present the networks as three separate wallets.

The user primarily chooses **how they want to connect**, then the wallet tells the app which supported networks/accounts are available.

---

# 3. Network Support

Internally the app supports:

```text
Ethereum
Polygon
Solana
```

But don't force users to choose:

```text
Choose blockchain:

○ Ethereum
○ Polygon
○ Solana
```

as the first step.

That makes the product feel unnecessarily technical.

Instead:

```text
Connect wallet
        ↓
Wallet connection
        ↓
Discover supported accounts/networks
        ↓
Show available balances
```

---

# 4. Connected Wallet State

Once connected, the Home screen changes completely.

Header:

```text
Good morning

[Wallet avatar]
0x8F...42A1
```

or for Solana:

```text
7xK...91aP
```

The wallet address should always be shortened.

---

# 5. Balance Architecture in the UI

Because the user can have assets on multiple chains, don't make the balance card say:

```text
$1,245 USDC
```

unless that is actually the aggregate balance.

Instead:

```text
Total balance

$1,245.80
```

Then:

```text
USDC
$1,245.80
```

If the user has multiple supported assets:

```text
Total balance

$2,430.20

USDC       $1,800.00
USDT         $430.20
ETH          $200.00
```

Initially, the product can focus on stablecoins.

---

# 6. Home — Wallet Connected

```text
┌──────────────────────────────┐
│ Good morning          ◉      │
│ 0x8F...42A1                  │
│                              │
│ ┌──────────────────────────┐ │
│ │ Total balance             │ │
│ │                          │ │
│ │ $1,245.80                │ │
│ │                          │ │
│ │ USDC                     │ │
│ │ $1,245.80                │ │
│ └──────────────────────────┘ │
│                              │
│ What do you want to do?      │
│                              │
│ ┌──────────┐ ┌──────────┐   │
│ │ ↑        │ │ 📱       │   │
│ │ Send     │ │ Airtime  │   │
│ └──────────┘ └──────────┘   │
│                              │
│ ┌──────────┐ ┌──────────┐   │
│ │ ⚡       │ │ 📺       │   │
│ │Electricity│ │ TV       │   │
│ └──────────┘ └──────────┘   │
│                              │
│ Recent activity       See all│
│                              │
│ ↑ Bank transfer        ₦100k│
│ ⚡ Electricity          ₦10k│
│                              │
├──────────────────────────────┤
│ Home Activity Pay Profile    │
└──────────────────────────────┘
```

---

# 7. Home — No Wallet Connected

If the user chose "I'll do this later", Home should NOT display a fake balance.

Instead:

```text
Good morning

┌──────────────────────────────┐
│                              │
│       Connect your wallet    │
│                              │
│  Connect a wallet to see     │
│  your balance and start      │
│  paying with crypto.         │
│                              │
│     [ Connect wallet ]       │
│                              │
└──────────────────────────────┘
```

Below that, you can still show what the app does:

```text
Pay for everyday things

Send money
Airtime
Data
Electricity
TV
```

But the actual payment actions should prompt wallet connection.

---

# 8. Multiple Networks

The user may have:

```text
Ethereum
0x8F...42A1

Polygon
0x8F...42A1

Solana
7xK...91aP
```

These should be treated as **one connected wallet profile**, not three completely separate accounts in the UI.

The user should see:

```text
Connected wallets

Ethereum       0x8F...42A1
Polygon        0x8F...42A1
Solana         7xK...91aP
```

---

# 9. Network Indicator

When the user is about to make a payment, the app needs to communicate which network will actually be used.

For example:

```text
Pay with

USDC
Solana
```

or:

```text
Pay with

USDC
Polygon
```

This is important because USDC exists on multiple networks.

But don't make the network selector unnecessarily technical.

Use a simple bottom sheet:

```text
Choose payment network

┌──────────────────────────────┐
│ ✓  Solana                    │
│    USDC · $120.50            │
└──────────────────────────────┘

┌──────────────────────────────┐
│    Polygon                   │
│    USDC · $80.20             │
└──────────────────────────────┘

┌──────────────────────────────┐
│    Ethereum                  │
│    USDC · $20.00             │
└──────────────────────────────┘
```

The user chooses the network **only when necessary**.

---

# 10. Smart Network Selection

Eventually, don't even ask the user every time.

If a payment provider supports:

```text
Solana
```

and the user has enough USDC on Solana:

```text
USDC on Solana
$120.50
```

make that the default.

If the user has insufficient Solana USDC but enough Polygon USDC:

```text
USDC on Polygon
```

can become the available option.

The app should recommend the easiest/cheapest supported route.

The user can still manually change it.

---

# 11. Payment Review

The payment review should clearly show:

```text
You're paying

67.68 USDC

USDC on Solana
```

Not merely:

```text
67.68 USDC
```

For a user who has USDC on multiple chains, the network matters.

Example:

```text
Payment

₦100,000

You'll pay

67.68 USDC

Solana

Network fee
~0.01 USDC
```

---

# 12. Wallet Connection Status

The header should have a subtle wallet indicator.

Connected:

```text
◉ 0x8F...42A1
```

Disconnected:

```text
○ Connect wallet
```

Don't make it look like an account/login button.

It's a wallet connection.

---

# 13. Wallet Switcher

If the user has multiple networks/accounts available, tapping the wallet indicator opens:

```text
Wallets

Connected

┌──────────────────────────────┐
│ Solana                       │
│ 7xK...91aP                  │
│ $120.50 USDC                 │
│ ✓ Active                     │
└──────────────────────────────┘

┌──────────────────────────────┐
│ Polygon                      │
│ 0x8F...42A1                 │
│ $80.20 USDC                  │
└──────────────────────────────┘

┌──────────────────────────────┐
│ Ethereum                     │
│ 0x8F...42A1                 │
│ $20.00 USDC                  │
└──────────────────────────────┘

+ Connect another wallet
```

---

# 14. Wallet Details

Wallet screen:

```text
Wallet

Total balance

$1,245.80

────────────────────

Networks

Solana
7xK...91aP

USDC
$1,000.00

Polygon
0x8F...42A1

USDC
$200.00

Ethereum
0x8F...42A1

USDC
$45.80
```

The network should have its own subtle icon.

---

# 15. Disconnect

Disconnecting should be explicit.

Bottom sheet:

```text
Disconnect wallet?

You'll need to reconnect your wallet
before you can make payments.

[Cancel]

[Disconnect]
```

Do not make it feel like deleting an account.

---

# 16. Important Product Rule

The app should never imply that the app itself owns the user's crypto.

Avoid language such as:

```text
Your funds are stored here.
```

Instead:

```text
Connected wallet
```

or:

```text
Available in your wallet
```

The wallet remains the user's wallet.

---

# 17. Network-Aware Payment UX

The general payment flow becomes:

```text
Choose what you want to pay
          ↓
Enter NGN amount
          ↓
Recipient/service
          ↓
Get quote
          ↓
App determines supported payment networks
          ↓
User selects/reviews network if necessary
          ↓
Review USDC amount
          ↓
Open wallet
          ↓
User signs
          ↓
Processing
          ↓
Success
```

The blockchain remains behind the scenes.

---

# 18. What the Agent Should Design

Before writing the production Flutter widgets, create the complete UI for these states:

### Wallet states

```text
No wallet
Connect wallet
Connecting
Connected
Multiple networks
Wallet disconnected
Wallet connection failed
```

### Home states

```text
No wallet
Wallet connected
Loading balances
Balance loaded
Balance unavailable
```

### Payment states

```text
Entering payment
Quote loading
Quote loaded
Network selection
Review
Wallet approval
Wallet rejected
Transaction submitted
Processing
Success
Failed
Expired
```

### Service states

```text
Airtime
Data
Electricity
TV
Bank transfer
```

---

# 19. Critical Design Decision

Do **not** make Ethereum, Polygon and Solana three separate experiences.

The product abstraction is:

```text
             YOUR APP
                 │
          ┌──────┴──────┐
          │             │
       What?          How?
          │             │
     Bank transfer    Wallet
     Airtime          ↓
     Electricity    Network
     Data             ↓
     TV             USDC
```

The user chooses **what they want to accomplish**.

The app handles **how the crypto payment happens**.

That's the UX that will make this feel like a real consumer product rather than a crypto developer tool.