---
layout: post
title: "The CouchDB Replicator Database - An Overview"
author: "@codehakase"
imagefeature: "https://i.pinimg.com/originals/cc/7a/44/cc7a4487b4a69a8169ed62da74a6180b.jpg"
description: "An overview of how the replicator database works in CouchDB, and how to setup replication like a Boss."
modified: 2018-04-19
tags: [couchdb,databases,nosql]
share: true
comments: true
category: [databases,couchdb,nosql]
---

**TL;DR:** In this article, I'll give an overview of the replicator database in CouchDB, how to spin off a replication task in CouchDB

---

**CouchDB** is a database that completely embraces the web. CouchDB stores your data as JSON documents, and allows you access these documents easily, from a web interface or its [REST API](http://docs.couchdb.org/en/2.1.1/api/basics.html#api-basics). We won't be going too deep into couchdb as it would be out of scope for this article - I'll write one of those pretty soon.


## Replication in CouchDB
Replication involves a source and a destination database, which can co-exist on the same or on different CouchDB instances. The sole purpose and aim of replication is that at the end of the process, all active documents on the source database are also in the destination database, and all documents deleted in the source databases are also deleted on the destination database.

### The Replicator Database
This database can exist on any CouchDB node. The replicator database is where you `PUT` or `POST` documents to trigger replications, and you issue a `DELETE` to cancel any ongoing replications set. The default label for the replicator database is *_replicator*. This name can be changed at any point in time from the CouchDB configuration.

> Before proceeding to replicating a database, note, for security reasons, CouchDB is by default configured to listen to localhost/127.0.0.1 only. That means it can't replicate remote CouchDB server(s). To allow remote replication, CouchDB has to bound to *0.0.0.0*, this is set on the source server. To change bind address, you can do so from the [Futon config page](http://localhost:5984/_utils/config.html) or locate `bind_address` in your CouchDB config.

### Structure of the Replicator Database Documents
To trigger a replication, you create a document in the **_replicator** database. Its structure should look like this:

```
{
  "_id": "test_replication",
  "source": "mydb",
  "target": "http://someserver.com:5984/mydb",
  "create_target": true
}
```

Saving the above document, the couchdb daemon triggers a replication, with the content of the document. A log entry should look like these:
```
[Thu, 18 Apr 2018 19:43:59 WAT] [info] Document `test_replication` triggered replication `REV_+create_target`
[Thu, 18 Apr 2018 19:44:37 WAT] [info] Replication `REV_+create_target` finished (triggered by document `test_replication`)
```

When a replication is triggered, the document is updated by CouchDB some new fields:

```
{
  "_id": "test_replication",
  "source": "mydb",
  "target": "http://someserver.com:5984/mydb",
  "create_target": true,
  "_replication_id": "some-id-goes-here",
  "_replication_state": "triggered",
  "_replication_state_time": "2018-04-18T19:46:32"
}
```
Little note on the new fields added by CouchDB:

- **_replication_id** - This is the ID assigned to the replication operation
- **_replication_state** - The current state of the replication
- **_replication_state_time** - The timestamp that tells when the current replication state was set

### Duplicate Replication Documents?
There could be a case where two or more documents are added to the **_replicator** database, defining the same replication operation:

```
// first document
{
  "_id": "replication_1",
  "source": "mydb",
  "target": "http://someserver.com:5984/mydb"
}

// second document
{
  "_id": "replication_2",
  "source": "mydb",
  "target": "http://someserver.com:5984/mydb"
}
```
From the above we can tell that both document defines the same replication, only difference is the document ids. CouchDB will definitely trigger this replication, but this time something else happens. The first document `replication_1`, may trigger the replication, CouchDB updates the doc with the fields `_replicaton_id, _replication_state, and _replication_state_time`. However, the second document `replication_2` doesn't get updated with same fields, instead, CouchDB upadates with just one field - `_replication_id`, which is the same set on the first document.

```
// after replication is triggered

// first document
{
  "_id": "replication_1",
  "source": "mydb",
  "target": "http://someserver.com:5984/mydb",
  "_replication_id": "my-sample-replication-id",
  "_replication_state": "triggered",
  "_replication_state_time": "2018-04-18T19:46:32"

}

// second document
{
  "_id": "replication_2",
  "source": "mydb",
  "target": "http://someserver.com:5984/mydb",
  "_replication_id": "my-sample-replication-id"
}
```

### Cancelling Replications
To cancel an ongoing replication, you simply delete the document which triggered the replication.


### Typical Replication Procedure
During replication, CouchDB compares the source and destination databases, to determine which documents differ between them. How does CouchDB determine these? It does so by following the [Changes Feeds](http://docs.couchdb.org/en/2.1.1/api/database/changes.html#changes) on the source database, and comparing the documents to the destination database. Changes are submitted to the destination in batches where they can introduce conflicts. If a document already exist on the destination, and has the same revision, it is not transferred.

A replication task will finish once it reaches the end of the changes feed. If its continuous property is set to true, it will wait for new changes to appear until the task is canceled. Replication tasks also create checkpoint documents on the destination to ensure that a restarted task can continue from where it stopped, for example after it has crashed.

### References
[Introduction to CouchDB Replication - Guide](http://docs.couchdb.org/en/2.1.1/replication/intro.html?highlight=Replication)

## Conclusion
Hurray! We've just wrapped up an overview of the CouchDB replicator database, and a little of the replication terminology.

I'll tend to write more on this topic, as it is a broad one.

Did I miss something important? Let me know in the comments below :D
