# Draft Intermagnet MQTT service description #

NOTE: This document is a draft and is presented for comments.


## Introduction ##

In order to meet the needs of its users, in particular researchers in space weather, Intermagnet wishes to 
improve the performance of its real-time provisional data service. Target latencies for 
the service are 2 minutes for 1-minute cadence provisional geomagnetic data and 30 seconds for 1-second data.
Two technologies are being trialled in an attempt to meet this goal:

- Seedlink
- MQTT

Seedlink is already in use at the American and Canadian Geomagnetic Information Nodes (GINs). A trial transfer 
of data using Seedlink will be made between these GINs and the Edinburgh GIN (operating as the Intermagnet data
portal). This work is described elsewhere.

This draft document describes an MQTT service to be implemented at the Edinburgh GIN for use by
other GINs and individual Intermagnet Observatories (IMOs). The aim of the service is to allow transfer of
provisional geomagnetic data in near real-time, optionally including the ability to specify all metadata
that the Edinburgh GIN stores alongside the data.


## MQTT architecture ##

![Diagram of MQTT implementation at the Edinburgh GIN](https://github.com/INTERMAGNET/wg-www-gins-data-formats/assets/9884468/890b29c8-08b4-4f94-87da-78f1d80d1237)
MQTT implementation at the Edinburgh GIN

A public facing [Mosquito](https://mosquitto.org/) MQTT broker will run at the British Geological Survey
(BGS) at the Internet address gin-mqtt.bgs.ac.uk. IMOs and GINs (clients at insititutes A,B,C,... in the
diagram) will be authorised to publish to individual topics on the broker. An internal client at BGS will 
subscribe to all topics in the broker, and will thus receive all messages sent by all IMOs and GINs.


## Topic design ##

The MQTT broker will be dedicated to Intermagnet traffic and will not be used for other messages.
The Edinburgh GIN is the primary "consumer" of data sent to the MQTT broker. The Edinburgh GIN will receive all
messages sent to the broker, and so does not need to use topics to filter the messages it receives. However topics
can aid in the design of security for the system (by only allowing a limited set of clients to publish data for
each observatory). In the future it may also be useful to allow other clients (possibly outside Intermagnet)
to subscribe to data from the broker. For this reason it makes sense to design topics that aid filtering of
the data sent to the broker.

GINs and IMOs publishing data at the Intermagnet MQTT service muse use the topic:

```
<iaga-code>/<cadence>/<publication-level>
```

Where:

- "iaga-code" is the IAGA registered code of the observatory sending data
- "cadence" is the sample period for the data as an ISO8601 duration. Since the
  Edinburgh GIN only accepts 1-second and 1-minute data, the only valid cadences
  are "pt1s" and "pt1m".
- "publication-level" is a number indicating the level of processing applied to the data:

  - 1 = The data is unprocessed and as recorded at the observatory with no changes made.
  - 2 = Some edits have been made such as gap filling and spike removal and a preliminary baseline added.
  - 3 = The data is at the level required for production of an initial bulletin or for quasi-definitive publication.
  - 4 = The data has been finalised and no further changes are intended.

### Examples ###

The topic for Eskdalemuir observatory's 1-minute "reported" data (straight from the observatory with no processing)
would be:

```
esk/pt1m/1
```

The topic for Lerwick observatory's 1-second quasi-definitive data would be:

```
ler/pt1s/3
```


## Quality of service ##

For a helpful discussion of MQTT quality of service (QoS) see 
[here](https://www.hivemq.com/blog/mqtt-essentials-part-6-mqtt-quality-of-service-levels/).

The Edinburgh GIN uses rules when ingesting individual geomagnetic data samples into its 
database. These rules allow modification of geomagnetic data (a more recent submission of 
data at a particular publication level will overwrite previous data values at the same
publication level), but prevent overwriting of valid data samples with missing data values 
(individual data samples can't be deleted).

One of the issues affecting the decision on what QoS level to use is whether the
underlying application receiving the data from MQTT can tolerate ingestion of duplicate 
messages. Delivering a duplicate message to the Edinburgh GIN will not cause any problems. 
However, if an IMO were to deliver two versions of the same data (at the same publication 
level), and the messages for version 1 were to be delayed and arrive after the messages 
for version 2, the version 1 data will overwrite the version 2 data. This scenario is unlikely.

The Edinburgh GIN will subscribe to the MQTT broker with a QoS of 2. IMOs and GINs
are recommended to publish with a QoS of 1, which reduces the overhead needed to manage
the message stream (since the lower of the two QoS levels is used between publisher and
subsriber). However, if the the scenario outlined above is thought to be an issue,
IMOs and GINs can publish using a QoS of 2, which guarantees that the order of messages 
will be maintained between publisher and subscriber (for messages published with a QoS of 2).

To enable QoS level 2 and to ensure messages are not missed, the Edinburgh GIN will
subscribe to the MQTT broker with a 
[persistant session](https://www.hivemq.com/blog/mqtt-essentials-part-7-persistent-session-queuing-messages/).


## Security ##

### Authentication and authorization ###

Each IMO or GIN will be assigned connection details that will be needed to publish data
on the Intermagnet MQTT service:

- A username. The username will be unique to the IMO or GIN and should not be shared.
- A password. The password is linked to the username.

The username given to each IMO or GIN will define which topics (and so which observatories)
the IMO of GIN can publish data to.

A client will also be allowed to subscribe to the topics that it can publish to.

### Secure transport ###

Only secure (TLS) connections will be accepted by the Intermagnet MQTT service. Open
(unecrypted) connections expose the authentication and authorization credentials used
to connect to the service, thereby risking publication of data from unauthorized sources,
and so will not be accepted.

The precise details of the TLS implementation (whether TLS is handled at the MQTT broker
or by an edge device on the BGS network) have still to be resolved. However it is expected
that the default port (8883) will be used for MQTT over TLS.

### ACLs and topics ###

Internally the authorization mechanisms will be managed using a Mosquitto Access Control List (ACL).
This file defines which topics a user is allowed to publish and subscribe to. Since topic names
start with the observatory IAGA-code, this list will provide a clear description of which users
are allowed to publish data for an observatory.

### Notes for clients ###

From a client perspective it isn’t easy to know if access control is being applied, as restrictions 
aren’t notified to the client (at least in MQTT v3.1.1). The way around this for a client wanting to
verify successful publication of data is to subscribe to a topic as well publishing and check whether 
any published messages are received through the subscription.


## MQTT payload format ##

The Intermagnet MQTT JSON format is designed to allow GINs and IMOs to deliver
real-time data to the Intermagnet data portal using Intermagnet's MQTT
service. JSON data segments in this format form the payload of MQTT
messages. The precise format of the Json data segments is constrained by the 
[JSON schema for the format](ImagMQTTSchema.json). MQTT payloads must consist
of JSON documents conforming to the schema and no other content.

The JSON schema consists of three sections:

1. Mandatory metadata
2. Mandatory geomagnetic field data
3. Optional extra metadata

The mandatory metadata consists of 5 fields, all of which must be present in every
JSON data message:

1. "iagaCode": The observatory's IAGA code.
2. "elementsRecorded": A list of geomagnetic field elements recorded in the data,
   1 character per element. Valid values are constrained by a list, which can
   be seen in the [schema definition](ImagMQTTSchema.json).
3. "startDate": The date and time of the first data sample, in ISO8601 format. The
   string is truncated to the appropriate precision for the data cadence (ie. all
   fields except milli-seconds for 1-second data, all fields except seconds and
   milli-seconds for 1-minute data).
4. "cadence": The sample period for the data as an ISO8601 duration. Since the
   Edinburgh GIN only accepts 1-second and 1-minute data, the only valid cadences
   are "pt1s" and "pt1m".
5. "publicationLevel": A number indicating the level of processing applied to the data:

  - 1 = The data is unprocessed and as recorded at the observatory with no changes made.
  - 2 = Some edits have been made such as gap filling and spike removal and a preliminary baseline added.
  - 3 = The data is at the level required for production of an initial bulletin or for quasi-definitive publication.
  - 4 = The data has been finalised and no further changes are intended.

The mandatory geomagnetic field data consists of either 3 or 4 arrays. The arrays must all be
the same length and contain only numbers or the value "null" to indicate a missing sample. Valid arrays are:

- "geomagneticFieldX": Magnetic field vector strength in nT, x component, geographic coordinates.
- "geomagneticFieldY": Magnetic field vector strength in nT, y component, geographic coordinates.
- "geomagneticFieldZ": Magnetic field vector strength in nT, z component, geographic coordinates.
- "geomagneticFieldH": Magnetic field vector strength in nT, in the horizontal plane along the magnetic meridian.
- "geomagneticFieldD": Angle between the magnetic vector and true north, in degrees of arc, positive east.
- "geomagneticFieldI": Angle between the magnetic vector and the horizontal, in degrees of arc, positive below the horizontal.
- "geomagneticFieldF": Geomagnetic field strength in nT, calculated from and consistent with XYZ or HDZ field elements.
- "geomagneticFieldS": Geomagnetic field strength in nT, measured by an independent scalar instrument.

The arrays present in the JSON data message must correspond to the "elementsRecorded" metadata field.

The optional extra metadata may be completely missing, or any part of parts may be included.
The purpose of this metadata is to allow the data provider to supply metadata values that the Intermagnet
data portal will use when creating IMF, IAGA-2002 and ImagCDF data files for users. The data portal
stores a metadata file for each day and publication level of data. Thus it is only neccessary
for a data provider to send one message per day / publication level, containing the optional metadata that
they require to be distributed with their data. Subsquent messages for the same day / publication level
do not require any optional medata. If data provider's follow this advice, it is best
to provide the optional metadata along with the first data of the day, to ensure that data and
metadata are always consistent.

If the optional metadata is not supplied, default values will be used by the portal (from static
metadata that the Edinburgh GIN holds)).

The following optional metadata fields are available - the names in brackets after each of the
fields describes which data distribution format(s) the metadata field is used in:

- "ginCode": (IMF)
- "decbas": (IMF)
- "latitude": (IMF, IAGA-2002, ImagCDF)
- "longitude": (IMF, IAGA-2002, ImagCDF)
- "elevation": (IAGA-2002, ImagCDF)
- "institute": (IAGA-2002, ImagCDF - called "Source of data" in IAGA-2002)
- "name": (IAGA-2002, ImagCDF - called "ObservatoryName" in ImagCDF)
- "sensorOrientation": (IAGA-2002, ImagCDF - called "VectorSensOrient in CDF)
- "digitalSampling": (IAGA-2002)
- "dataIntervalType": (IAGA-2002)
- "publicationDate": (IAGA-2002, ImagCDF)
- "standardLevel": (ImagCDF)
- "standardName": (ImagCDF)
- "standardVersion": (ImagCDF)
- "partialStandDesc": (ImagCDF)
- "source": (ImagCDF)
- "termsOfUse": (ImagCDF)
- "uniqueIdentifier": (ImagCDF)
- "parentIdentifiers": (ImagCDF)
- "referenceLinks": (ImagCDF)
- "comments": (IAGA-2002)

For details of each of these fields, see the [JSON schema](ImagMQTTSchema.json).

Data sets created for this schema can be checked at the JSON Schema verfier:
https://json-schema.hyperjump.io/. Reference material for JSON Schema is here:
https://json-schema.org/learn/getting-started-step-by-step. The Schema for 
Intermagnet MQTT JSON is [here](ImagMQTTSchema.json).

An example JSON data file is [here](ImagMQTTExample1.json). This is an example
of a minimum viable data file for 1-minute data. A single 3-component sample is
presented along with mandatory metadata. An expanded example [here](ImagMQTTExample2.json) 
shows how to add "comment" metadata, to set the "comments" section when the data is
distributed in IAGA-2002 format. This example also shows how the startDate should be
modified for 1-second data.

