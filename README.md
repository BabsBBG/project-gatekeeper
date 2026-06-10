<div align="center">

# Project Gatekeeper

### Post─Acquisition Identity Security Framework

**Helix Communications × Pulse Networks**

─

![Microsoft Entra ID](https://img.shields.io/badge/Microsoft%20Entra%20ID─0078D4?style=for─the─badge&logo=microsoftazure&logoColor=white)
![Microsoft Sentinel](https://img.shields.io/badge/Microsoft%20Sentinel─0078D4?style=for─the─badge&logo=microsoftazure&logoColor=white)
![Azure Logic Apps](https://img.shields.io/badge/Logic%20Apps─0066FF?style=for─the─badge&logo=microsoftazure&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform─7B42BC?style=for─the─badge&logo=terraform&logoColor=white)
![KQL](https://img.shields.io/badge/KQL─00B4D8?style=for─the─badge&logo=microsoftazure&logoColor=white)
![SC─300](https://img.shields.io/badge/SC─300─0078D4?style=for─the─badge&logo=microsoft&logoColor=white)
![AZ─500](https://img.shields.io/badge/AZ─500─0078D4?style=for─the─badge&logo=microsoft&logoColor=white)

─

| Phases Built | CA Policies | KQL Detection Rules | Containment Time |
---:|:---:|:---:|:---:|
| **6** | **7** | **14** | **2.42 seconds** |

</div>

─

## The Real Story

Years ago I worked the NOC floor for Legend Internet, a Nigerian ISP. I watched our biggest competitor, Spectranet, eat into our subscriber base for years. Then in March 2026, Legend announced plans to merge with Spectranet — a real telecom acquisition with all the identity chaos that comes with it.

Project Gatekeeper simulates that exact scenario. Helix Communications, a UK ISP, acquires Pulse Networks. Overnight, the identity attack surface doubles:

─ 400+ Pulse identities — inconsistent naming, no offboarding process
─ No MFA on legacy accounts
─ Stale accounts and over─privileged users
─ Unmanaged contractor and partner access
─ Zero detection or automated response

I built a complete identity security framework to fix this. Six phases, 14 custom KQL detection rules mapped to MITRE ATT&CK, 10 live attack simulations with evidence, and a SOAR playbook that contains a compromised account in **2.42 seconds**.

| Metric | Before | After |
|---|---|---|
| MFA enforcement | 0% | **100% via CA001** |
| Legacy authentication | Enabled | **Blocked ─ CA002** |
| Privileged roles | Permanent Global Admin | **JIT with dual approval** |
| Custom detection rules | None | **14 KQL rules** |
| Incident response | Manual ─ hours | **SOAR ─ under 3 seconds** |
| Identity Secure Score | N/A | **32.04%** |

─

## Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                   HELIX COMMUNICATIONS TENANT                    │
│                                                                   │
│  ┌──────────────────┐    ┌──────────────────────────────────┐   │
│  │  PULSE LEGACY    │    │       CONDITIONAL ACCESS          │   │
│  │                  │───▶│  CA001  CA002  CA003  CA004      │   │
│  │  400+ identities │    │  CA005  CA006  CA007             │   │
│  │  No MFA · Stale  │    │  7 policies · all enforced       │   │
│  └──────────────────┘    └────────────────┬─────────────────┘   │
│                                           │                       │
│  ┌───────────────────┐   ┌───────────────▼─────────────────┐   │
│  │    PIM GATE       │   │        IDENTITY LIFECYCLE         │   │
│  │                   │   │                                   │   │
│  │  JIT · 4hr max    │   │  Joiner → TAP + Groups + Email  │   │
│  │  Dual approval    │   │  Mover  → Group update + Notify │   │
│  │  Zero standing    │   │  Leaver → Disable + Revoke +    │   │
│  └───────────────────┘   │           Strip + Notify         │   │
│                           └───────────────────────────────────┘  │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │                  ITDR DETECTION LAYER                       │  │
│  │  Entra ID Protection  ·  14 KQL Rules  ·  Sentinel         │  │
│  └──────────────────────────────┬──────────────────────────── ┘  │
│                                 │ High severity incident          │
│  ┌──────────────────────────────▼──────────────────────────── ┐  │
│  │              HLX-SOAR-HighRiskResponse                      │  │
│  │  Revoke Sessions → Disable Account → HLX-Offboarding       │  │
│  │  → Leaver Workflow → SOC Email                2.42 seconds  │  │
│  └─────────────────────────────────────────────────────────── ┘  │
└───────────────────────────────────────────────────────────────────┘
```
───

## Phase 1 ─ Identity Baseline

**Goal:** Understand what Pulse brought in, then lock down the foundation before a single legacy identity touches the Helix environment.

### Security Groups

Seven groups: IT Admins, NOC Engineers, Corporate Staff, Field Ops, Break─Glass, PIM Approvers, and Pulse Legacy Users. HLX─IT─Admins is role─assignable — required for PIM in Phase 3.

![Groups list](<Phase 1/phase1─task2─groups─list.png>)

### Break─Glass Accounts

Two accounts (`bg─01`, `bg─02`) with permanent Global Administrator. Credentials stored offline and never used day─to─day. Excluded from all CA policies and all SOAR automation.

![Break─glass members](<Phase 1/phase1─task3─breakglass─members.png>)
![BG─01 roles](<Phase 1/phase1─task3─breakglass─bg01─roles.png>)

### Bulk User Creation via PowerShell

16 users created in one script using Microsoft Graph PowerShell. Each Pulse legacy account (prefixed `pls─`) was created with a documented gap: no MFA, stale, over─privileged, or unlicensed.

![PowerShell creation](<Phase 1/phase1─task4─powershell─creation.png>)
![Users list](<Phase 1/phase1─task4─users─list.png>)

### Licensing and Authentication Methods

M365 E5 licences assigned to all users. Authentication methods hardened: Microsoft Authenticator, FIDO2, and Temporary Access Pass enabled. SMS and voice calls disabled.

![Auth methods](<Phase 1/phase1─task6─auth─methods.png>)

### SSPR

Self─service password reset enabled for all users, two methods required.

![SSPR properties](<Phase 1/phase1─task7─sspr─properties.png>)
![SSPR methods](<Phase 1/phase1─task7─sspr─methods.png>)

### Pulse Legacy Gap Remediation

─ Disabled `pls─jakub.kiwior` — stale, no activity since acquisition close
─ Removed inherited AI Reader and Directory Readers roles from `pls─reiss.nelson` — assigned outside any governance framework

![Kiwior disabled](<Phase 1/phase1─task8─kiwior─disabled.png>)
![Nelson inherited roles](<Phase 1/phase1─task8─nelson─roles.png>)

───

## Phase 2 ─ Conditional Access Architecture

**Goal:** Control who can sign in, from where, and under what conditions — across two merged organisations with different risk profiles.

### Named Locations

Five locations defining the network topology. Helix─NOC─Floor is trusted. Both Pulse locations are known but not trusted — they generate additional scrutiny.

![Named locations](<Phase 2/phase2─task1─named─locations.png>)

### Seven CA Policies

| Policy | Scope | Control |
|---|---|---|
| CA001 | All users | Require MFA — break─glass excluded |
| CA002 | All users | Block legacy auth (ActiveSync, other clients) |
| CA003 | All users — High/Medium sign─in risk | Require MFA + re─auth every time |
| CA004 | All users — High user risk | MFA + forced password change |
| CA005 | HLX─IT─Admins | MFA + 4hr session, never persistent |
| CA006 | Guest/contractor users | MFA + 1hr session |
| CA007 | Pulse─Partner─Network location | MFA + 2hr session |

All policies started in report─only mode and were moved to enforcement once the environment stabilised — standard enterprise deployment practice.

![CA policy list](<Phase 2/phase2─task2─all─policies─list.png>)
![CA001](<Phase 2/phase2─task2─ca001─require─mfa.png>)
![CA002](<Phase 2/phase2─task2─ca002─block─legacy─auth.png>)
![CA003 sign─in risk](<Phase 2/phase2─task2─ca003─signin─risk.png>)
![CA007 Pulse partner](<Phase 2/phase2─task2─ca007─pulse─partner.png>)

──

## Phase 3 ─ Privileged Identity Management

**Goal:** Zero standing privilege. Every admin role activated just─in─time, with justification and where required, approval from someone outside the IT Admin tier.

### Role Settings

| Role | Max Duration | MFA | Approval |
|---|---|---|---|
| Global Administrator | 4 hours | Required | Required — HLX─PIM─Approvers |
| Security Administrator | 8 hours | Required | Not required |
| Privileged Role Administrator | 4 hours | Required | Required — HLX─PIM─Approvers |

![Global Admin settings](<Phase 3/phase3─task2─globaladmin─settings.png>)

### Eligible Assignments

Odegaard → Global Admin. Rice → Security Admin. Saliba → Privileged Role Admin. None are active by default. Every elevation is a deliberate, auditable act.

![Eligible assignments](<Phase 3/phase3─task3─eligible─assignments.png>)

### Separation of Duties

HLX─PIM─Approvers consists of Jurrien Timber and Kai Havertz — Corporate staff, not IT Admins. They cannot approve their own requests because they have none to approve.

![PIM approvers group](<Phase 3/phase3─task4─pim─approvers─group.png>)
![Global Admin approvers configured](<Phase 3/phase3─task4─globaladmin─approvers.png>)

### Access Review

Global Administrator eligible assignments reviewed monthly by Timber. Auto─remove on non─response.

![Access review active](<Phase 3/phase3─task7─access─review.png>)

### Live Activation Simulation

Odegaard requested Global Admin → Timber approved from outside the IT Admin tier. Full audit trail captured.

![Activation request](<Phase 3/phase3─task9─activation─request.png>)
![Timber approval](<Phase 3/phase3─task9─timber─approval.png>)

──

## Phase 4 ─ Identity Lifecycle: JML Workflows

**Goal:** Replace manual helpdesk tickets with automated lifecycle workflows that respond in seconds, not days.

### Joiner

Trigger: user added to `HLX─New─Joiners`. Tasks: Generate Temporary Access Pass, assign default group, send welcome email. The TAP lets new users register MFA without an existing credential — breaking the circular dependency that would otherwise require a helpdesk call.

![Joiner workflow](<Phase 4/phase4─task2─joiner─workflow.png>)
![Joiner test](<Phase 4/phase4─task5─joiner─test.png>)

### Mover

Trigger: department attribute change. Tasks: Remove previous group, add new group, notify manager.

![Mover workflow](<Phase 4/phase4─task3─mover─workflow.png>)
![Mover test](<Phase 4/phase4─task6─mover─test.png>)

### Leaver

Trigger: user added to `HLX─Offboarding`. Tasks: Disable account, revoke all sessions, remove all groups, strip licences, notify manager before and on final day.

![Leaver workflow](<Phase 4/phase4─task4─leaver─workflow.png>)
![Leaver test](<Phase 4/phase4─task7─leaver─test.png>)
![Lokonga disabled](<Phase 4/phase4─task7─lokonga─disabled.png>)

The leaver workflow also serves as an **emergency containment trigger**. The SOAR playbook in Phase 6 adds compromised accounts to HLX─Offboarding, immediately chaining into the full offboarding sequence.

──

## Phase 5 ─ ITDR: Threat Detection

**Goal:** Build detection rules that catch Pulse─specific threats, then prove they work with live evidence.

### 14 Custom KQL Rules — MITRE ATT&CK Mapped

All 14 rules deployed as Sentinel scheduled analytics and available in [`/kql─queries/`](kql─queries/).

| Rule | Threat | Severity | Tactic | Technique |
|---|---|---|---|---|
| HLX─DETECT─001 | Break─Glass Account Access | **High** | Initial Access | T1078 |
| HLX─DETECT─002 | Impossible Travel | **High** | Initial Access | T1078 |
| HLX─DETECT─003 | Password Spray | **High** | Credential Access | T1110.003 |
| HLX─DETECT─004 | Role Assigned Outside PIM | **High** | Privilege Escalation | T1098.003 |
| HLX─DETECT─005 | Pulse Legacy Account Activity | Medium | Initial Access | T1078.004 |
| HLX─DETECT─006 | MFA Fatigue / Push Bombing | Medium | Defense Evasion | T1621 |
| HLX─DETECT─007 | Legacy Auth Post─Migration | Medium | Defense Evasion | T1550 |
| HLX─DETECT─008 | After─Hours NOC Access | Medium | Initial Access | T1078 |
| HLX─DETECT─009 | Mass Group Membership Change | **High** | Privilege Escalation | T1098.001 |
| HLX─DETECT─010 | Offboarding Workflow Bypass | Medium | Defense Evasion | T1098 |
| HLX─DETECT─011 | PIM Activation Outside Window | **High** | Privilege Escalation | T1078.004 |
| HLX─DETECT─012 | Pulse Account Impossible Travel | **High** | Initial Access | T1078 |
| HLX─DETECT─013 | Pulse Partner Network Anomaly | Medium | Initial Access | T1078 |
| HLX─DETECT─014 | Risk─Alert Correlation | **High** | Initial Access | T1078 |

![KQL folder](<Phase 5/phase5─task4─kql─folder.png>)

### 10 Live Attack Simulations

> *A KQL rule that fires but does nothing is a ticket generator. A Sentinel incident that triggers a Logic Apps playbook that revokes, disables, and offboards — that's security.*

Every simulation generated real log entries in the Helix tenant. Advanced Hunting and Entra audit log evidence was captured for 12 of 14 rules.

──

**Simulation 1 — Credential Harvest** (Rules 1, 5)

Attack Simulation Training launched against all four Pulse legacy accounts. Real phishing campaign — real sign─in activity logged.

![Credential harvest results](<Phase 5/phase5─sim1─credential─harvest─results.png>)
![Phish page — Zinchenko](<Phase 5/phase5─sim1─phish─page─zinchenko.png>)

──

**Simulation 2 — Password Spray** (Rule 2)

Manual failed logins cycled across all four Pulse accounts from the same browser and IP. Multiple failed attempts, multiple targets, short time window — the signature spray pattern.

![Password spray logs](<Phase 5/phase5─sim2─password─spray─logs.png>)

──

**Simulation 3 — Role Assigned Outside PIM** (Rule 4)

Direct Security Reader assignment to a Pulse legacy user bypassing PIM entirely. Audit log captured the assignment. Role removed immediately after.

![Role outside PIM audit](<Phase 5/phase5─sim3─role─outside─pim─audit.png>)

──

**Simulation 4 — Mass Group Membership Change** (Rule 9)

Added three users simultaneously to HLX─IT─Admins. Audit log shows bulk additions in a single 15─minute window — the pattern Rule 9 targets.

![Mass group change audit](<Phase 5/phase5─sim4─mass─group─change─audit1.png>)
![Mass group change detail](<Phase 5/phase5─sim4─mass─group─change─audit2.png>)

──

**Simulation 5 — Break─Glass Account Access** (Rule 13)

Signed in as bg─01 from an incognito window. CA policies correctly showed Not Applied — break─glass exclusion working. Identity Protection flagged the unfamiliar IP and interrupted the flow, but the sign─in completed. This is the correct behaviour — emergency access must never auto─block.

![Break─glass signin](<Phase 5/phase5─sim5─breakglass─signin.png>)
![CA policies not applied](<Phase 5/phase5─sim5─breakglass─ca─not─applied.png>)
![Identity Protection interrupted](<Phase 5/phase5─sim5─breakglass─interrupted.png>)
![Advanced Hunting evidence](<Phase 5/phase5─sim5─breakglass─advanced─hunting.png>)

──

**Simulation 6 — Offboarding Workflow Bypass** (Rule 10)

Disabled pls─reiss.nelson directly without adding to HLX─Offboarding first. Audit log shows AccountEnabled changed to false with no preceding offboarding group entry. Then attempted sign─in on the disabled account — 50057 error confirmed.

![Offboarding bypass audit](<Phase 5/phase5─sim6─offboarding─bypass─audit.png>)
![Account locked 50057](<Phase 5/phase5─sim6─account─locked.png>)

──

**Simulation 7 — MFA Fatigue** (Rule 6)

Repeatedly signed in as Bukayo Saka and denied the MFA push each time. Sign─in logs show the Interrupted → Interrupted → Interrupted → Success pattern — exactly what push bombing looks like in logs.

![MFA fatigue sign─in logs](<Phase 5/phase5─sim7─mfa─fatigue─signin─logs.png>)
![MFA fatigue Advanced Hunting](<Phase 5/phase5─sim7─mfa─fatigue─advanced─hunting.png>)

──

**Simulation 8 — Legacy Authentication** (Rule 7)

PowerShell sent a Basic Auth HTTP request to the Exchange MAPI endpoint. 401 Unauthorized — CA002 blocked it at the protocol level.

![Legacy auth 401](<Phase 5/phase5─sim8─legacy─auth─401.png>)

──

**Simulation 9 — Impossible Travel** (Rules 1, 12)

Signed in as pls─oleksandr.zinchenko from Nigeria, then immediately via VPN from the US and Belgium. Three countries in minutes. Sign─in logs and Advanced Hunting both capture the pattern.

![Impossible travel Advanced Hunting](<Phase 5/phase5─sim9─impossible─travel─advanced─hunting.png>)

> CA003 did not block this sign─in — and that is correct. Impossible travel is a post─sign─in detection. Both sign─in events must occur before the pattern can be calculated. By the time Identity Protection scores it, the session exists. CA004 catches the elevated user risk on the next sign─in. This is how the detection chain is designed.

──

**Simulation 10 — PIM Activation Anomaly** (Rule 11)

Odegaard activated Global Administrator. Full PIM audit log captured with timestamp — the evidence Rule 11 queries for out─of─window activations.

![PIM activation audit](<Phase 5/phase5─sim10─pim─activation─audit.png>)

──

**VPN Risky Sign─in** (Baseline evidence — Rules 1, 5)

The first foreign VPN test that kicked off the detection work. Identity Protection flagged the sign─in, CA003 enforced MFA, and the risky sign─ins dashboard populated for the first time.

![Risky sign─ins](<Phase 5/phase5─vpn─risky─signins.png>)
![Risk detections](<Phase 5/phase5─vpn─risk─detections.png>)
![CA003 block](<Phase 5/phase5─vpn─ca003─block.png>)

──

## Phase 6 ─ Response Automation and Governance

**Goal:** Close the detection─to─response loop. Prove the whole system works end─to─end.

### Enable All CA Policies

No more report─only. All 7 policies enforced.

![All CA policies enabled](<Phase 6/phase6─task1─all─ca─enabled.png>)

### Access Reviews

Global Admin monthly review — Timber approved Odegaard. Pulse legacy quarterly review configured for external identities.

![Access review approval](<Phase 6/phase6─task2─access─review─approval.png>)
![Pulse legacy review](<Phase 6/phase6─task3─pulse─legacy─review.png>)

### Deploy Sentinel

Log Analytics workspace created. Entra ID, MDI, and M365 Defender data connectors connected. All 14 KQL rules deployed as scheduled analytics with MITRE ATT&CK tactic and technique mapping.

![Log Analytics workspace](<Phase 6/phase6─task4─law─workspace.png>)
![All 14 analytics rules active](<Phase 6/phase6─task4─all─analytics─rules.png>)
![Sentinel overview](<Phase 6/phase6─task4─sentinel─overview.png>)

### SOAR Playbook: HLX─SOAR─HighRiskResponse

**Trigger:** HTTP webhook — lab implementation. Production uses Sentinel incident automation rule.

```
Incident fires
    │
    ▼
Break─glass check ─ IS break─glass ─▶ P1 alert only, no action
    │
    │ NOT break─glass
    ▼
Sessions revoked (Graph API)
    │
    ▼
Account disabled (Entra ID)
    │
    ▼
Added to HLX─Offboarding
    │
    ▼
Leaver workflow fires — groups, licences, notifications
    │
    ▼
SOC alert email
    │
    ▼
Full containment — 2.42 seconds
```

![Logic App workflow](<Phase 6/phase6─task5─logicapp─workflow.png>)

### Live Test — pls─oleksandr.zinchenko

Playbook triggered via PowerShell webhook. All steps executed in 2.42 seconds.

![Run history — all green](<Phase 6/phase6─task5─logicapp─run─history.png>)
![Account disabled](<Phase 6/phase6─task5─account─disabled.png>)
![Added to HLX─Offboarding](<Phase 6/phase6─task5─offboarding─group─member.png>)
![SOC alert email](<Phase 6/phase6─task5─soc─alert─email.png>)

### Break─Glass Exclusion Test

bg─01 submitted to the playbook. Account not touched. P1 alert sent.

![Break─glass alert email](<Phase 6/phase6─task5─breakglass─alert─email.png>)
![Break─glass still enabled](<Phase 6/phase6─task5─breakglass─still─enabled.png>)

### Final Secure Score

32.04% post─acquisition, with the full control stack active. The score reflects bringing 400+ Pulse accounts into the MFA registration calculation — expected to climb above 70% as legacy users complete registration and controls continue to mature.

![Final Secure Score](<Phase 6/phase6─task6─final─secure─score.png>)

──

## What I Learned the Hard Way

**Lifecycle Workflows need Entra ID Governance** — a separate trial licence on top of E5. I activated the free trial and it unlocked immediately. Not obvious until you hit the 401 on the overview page.

**Access reviews in trial tenants** — the My Access portal sometimes doesn't surface PIM reviews for reviewers despite correct licence assignment and 24+ hours. The email notification with direct link works. The configuration is correct.

**Sentinel entity extraction is unreliable in trial workspaces** — the built─in Entities ─ Get Accounts action consistently returned empty results for both analytics─rule─generated and manually created incidents. Switched to an HTTP webhook trigger and passed the UPN directly. In a production Sentinel workspace with sufficient ingestion history, the native trigger works correctly. The response chain logic — revoke, disable, offboard, notify — is fully validated regardless of trigger method.

──

## Reproduce This Project

```bash
# Prerequisites: Terraform CLI, Azure CLI, M365 E5 trial tenant
az login
az account set ─subscription "your─subscription"

cd terraform
terraform init
terraform plan
terraform apply
```

Terraform covers: all Entra ID groups, all 21 users, all 7 CA policies, all 5 named locations, all PIM eligible assignments, Log Analytics workspace, Sentinel, and all 14 KQL analytics rules as scheduled analytics.

Resources deployed via alternative methods are documented in [`/terraform/README.md`](terraform/README.md):
─ Lifecycle Workflows ─ Entra ID portal, definitions in [`/scripts/`](scripts/)
─ Logic Apps SOAR ─ ARM template in [`/logic─apps/`](logic─apps/)

──

## Repository Structure

```
project-gatekeeper/
├── Phase 1/                    # 15 screenshots
├── Phase 2/                    # 11 screenshots
├── Phase 3/                    # 11 screenshots
├── Phase 4/                    # 7 screenshots
├── Phase 5/                    # 25 screenshots + 10 simulations
├── Phase 6/                    # 14 screenshots
├── kql-queries/                # 14 KQL detection rules
├── terraform/                  # Full IaC — Entra ID + Azure
│   └── modules/
│       ├── identity-baseline/
│       ├── conditional-access/
│       ├── pim/
│       └── sentinel/
├── scripts/
│   └── New-GatekeeperUsers.ps1
├── logic-apps/
│   └── hlx-soar-playbook.json
└── README.md
```

─

## Cert Alignment

| Domain | Cert |
|---|---|
| Implement identities in Microsoft Entra ID | SC─300 |
| Implement authentication and access management | SC─300 |
| Plan and implement identity governance | SC─300 |
| Manage identity and access | AZ─500 |
| Manage security operations | AZ─500 |

─

<div align="center">

**Built by Tobi Babalola** — now go secure something.

[![GitHub](https://img.shields.io/badge/GitHub─BabsBBG─181717?style=flat&logo=github)](https://github.com/BabsBBG)

</div>