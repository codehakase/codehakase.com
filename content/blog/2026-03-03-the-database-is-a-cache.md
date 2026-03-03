---
layout: post
title: "The Database Is a Cache"
author: "@codehakase"
description: "A note on file-first systems where agents derive structured state from source documents, and the database becomes a derived cache."
modified: 2026-03-03
tags: [ai, architecture, systems]
share: true
category: ai
---

The default way to build a data-backed application is database-first. Design a schema, build an application that reads and writes to it, render the results. The database is the source of truth. Everything else is downstream.

This made sense because applications could only operate on structured data. A billing system needed an **invoices** table with amounts, due dates, and payment statuses in well-defined columns. It couldn't look at a signed contract PDF and figure out the payment terms on its own.

That constraint is gone now.

### The Duplication Problem

In a database-first billing system, information gets created twice. First as a document: the signed contract with payment terms, line items, a billing schedule. Then again as structured data: rows in an **invoices** table that represent the same information in a format the application can query.

The contract is the original record. The database is a copy. Keeping them in sync is an ongoing cost, and when they drift (they always drift) the dashboard stops being trustworthy. The typical fix is better process. But the real issue is architectural: the system doesn't read the source document, so someone has to bridge the gap manually.

### The Contract Is the Record

An AI agent can read a contract PDF and extract payment terms, line items, and billing schedules. It can read a bank statement and match deposits to outstanding invoices. It can cross-reference an email thread where a discount was negotiated against the original proposal.

This means the source documents can be the record, not a copy of them in a database. The contract *is* the billing data. The bank statement *is* the payment record. The agent is the query layer that makes these documents addressable by the rest of the system.

A signed contract lands in a directory. The agent reads it and derives the structured data: net-30 terms, three line items, ₦12,000,000 total, billing starts March 1st. When a bank statement later shows a matching deposit, the agent reconciles it. The source documents drove the state. The database didn't need to be populated first.

The database still exists, but its role changes. It's a derived cache, generated for fast queries and dashboards. If it drifts, you regenerate it from the files. The files are the durable layer.

### Why This Matters for System Design

The observation here is about where truth lives in the system. In a database-first design, truth lives in the database, and everything upstream (documents, emails, contracts) is treated as transient input that gets discarded after entry. In a file-first design, truth lives in the source documents, and the database is a materialized view over them.

This changes how you think about a few things:

- Data integrity becomes a function of file organization, not schema enforcement.
- The application layer gets thinner because it's rendering derived state, not managing canonical state.
- The "records are out of date" problem goes away structurally, because the records *are* the source documents.
- Traceability becomes inherent. Every derived value in the cache can point back to the specific document and paragraph it was extracted from, rather than being an audit feature bolted on after the fact.

The agent is plumbing. Similar to how a database trigger or a materialized view keeps derived tables in sync, the agent keeps structured data in sync with the source files. The interesting architectural shift isn't the agent itself. It's that source documents can now be the system of record, because we finally have a query layer that can read them.

This is early thinking, and there are real open problems:

- Agent extraction is probabilistic, not deterministic. A misread decimal in a ₦12,000,000 contract is a serious error, and there's no schema constraint to catch it at write time.
- Recomputing the derived cache from thousands of source documents when extraction logic changes has a real cost.
- Treating source documents as the canonical record raises hard compliance questions. The right to deletion is straightforward in a database, less so when the record is a PDF you may be legally required to retain.

None of these are reasons to dismiss the model, but they're the problems that need solving before file-first moves from interesting to production-grade.

<div class="mx-auto" style="display: flex; justify-content: center;">
<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Wrote a new note on file-first systems and agents as a query layer over source documents. <a href="https://t.co/lxrHdpIGkm">pic.twitter.com/lxrHdpIGkm</a></p>&mdash; Sir Hakase (@codehakase) <a href="https://twitter.com/codehakase/status/2028803058549866589?ref_src=twsrc%5Etfw">March 3, 2026</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
</div>
