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

Public facing [Mosquito](https://mosquitto.org/) MQTT brokers will run at the British Geological Survey
(BGS) at the following Internet addresses:

- gin-mqtt.bgs.ac.uk - main Intermagnet/BGS MQTT service
- gin-mqtt-staging.bgs.ac.uk - development Intermagnet/BGS MQTT service

IMOs and GINs (clients at insititutes A,B,C,... in the diagram) will be authorised to publish to individual 
topics on the brokers. An internal client at BGS will subscribe to all topics in the broker, and will thus 
receive all messages sent by all IMOs and GINs.


## Topic design ##

The MQTT broker will be dedicated to Intermagnet traffic and will not be used for other messages.
The Edinburgh GIN is the primary "consumer" of data sent to the MQTT broker. The Edinburgh GIN will receive all
messages sent to the broker, and so does not need to use topics to filter the messages it receives. However topics
can aid in the design of security for the system (by only allowing a limited set of clients to publish data for
each observatory). In the future it may also be useful to allow other clients (possibly outside Intermagnet)
to subscribe to data from the broker. For this reason it makes sense to design topics that aid filtering of
the data sent to the broker.

GINs and IMOs publishing data at the Intermagnet MQTT service must use the topic:

```
impf/<iaga-code>/<cadence>/<publication-level>/<elements-recorded>
```

Where:

- "impf" stands for Intermagnet MQTT Payload Format and is included in the topic
  to allow alternative topic and payload formats to be used on the same MQTT
  brokers in the future
- "iaga-code" is the IAGA registered code of the observatory sending data
- "cadence" is the sample period for the data as an ISO8601 duration (for data
  with sampling rate of 1Hz or below) or the sample rate with the suffix "hz" (for
  data with sampling rate of 1Hz or above). Since the
  Edinburgh GIN only accepts 1-second and 1-minute data, the only valid cadences
  are "pt1s", "1hz" and "pt1m".
- "publication-level" is a number indicating the level of processing applied to the data:
  - 1 = The data is unprocessed and as recorded at the observatory with no changes made.
  - 2 = Some edits have been made such as gap filling and spike removal and a preliminary baseline added.
  - 3 = The data is at the level required for production of an initial bulletin or for quasi-definitive publication.
  - 4 = The data has been finalised and no further changes are intended.
- "elements-recorded" lists the geomagnetic elements that will be in the message and must be one of:
  - "XYZS"
  - "HDZS"
  - "DIFS"

Note that topics are case-sensitive. All topic values for the Intermagnet MQTT service
must be in lower case.

### Examples ###

The topic for Eskdalemuir observatory's 1-minute "reported" HDZ data (straight from the observatory with no processing)
would be:

```
impf/esk/pt1m/1/hdzs
```

The topic for Lerwick observatory's 1-second quasi-definitive XYZS data would be:

```
impf/ler/pt1s/3/xyzs
```

or 

```
impf/ler/1hz/3/xyzs
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
However, if an IMO or GIN were to deliver two versions of the same data (at the same publication 
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

### Importance of the MQTT Client ID ###

In MQTT, publication and subscription is associated with the subscriber's and publisher's client ID,
not the username. Only one client ID may be connected to an MQTT broker at at time. If a duplicate
client ID attempts to connect to a broker, the broker will disconnect the earlier connection. For these
reasons it is important that client IDs are selected so that there can never be any duplicate IDs.

The MQTT broker allows the username (used in authenticating with the broker) to be used as the
client ID. The only way to enforce unique client IDs is to allocate unique usernames to each
client (ie each observatory) and force clients to use the username as their client ID. This is
the approach used by the Intermagnet MQTT service.

### Authentication and authorization ###

Each IMO or GIN wishing to send data will be assigned connection details that will be 
needed to publish data on the Intermagnet MQTT service:

- A publication username. The username will be unique to the IMO or GIN and should not be shared.
  This username is used for publishing data.
- A publication password. The publication password is linked to the publication username.
- A subscription username. The username will be unique to the IMO or GIN and should not be shared.
  This username is used for subscribing to data, to allow an IMO or GIN to check that its
  data is being received.
- A subscription password. The subscription password is linked to the subscription username.

The usernames given to each IMO or GIN will define which topics (and so which observatories)
they can publish and subscribe to.

An IMO or GIN will be allowed to subscribe to the topics that it can publish to. Because
the client ID (specified by the username) can only connect once to a broker, it is
not possible to use one username to publish and subscribe at the same time. The username 
assigned for publication must be used only for publishing. A second username and password 
allows subscription at the same time as publication.

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

The mandatory metadata consists of a single which must be present in every
JSON data message:

1. "startDate": The date and time of the first data sample, in ISO8601 format. The
   string is truncated to the appropriate precision for the data cadence (ie. all
   fields except milli-seconds for 1-second data, all fields except seconds and
   milli-seconds for 1-minute data).

The topic used to publish data to the MQTT broker includes 4 further pieces of metadata
(IAGA code, cadence, publication level and geomagnetic orientation) that are also used 
to describe the data being transmitted.

The mandatory geomagnetic field data consists of anything between 1 and 4 arrays 
corresponding to the elements recorded (as described in the topic). Individual elements of the geomagnetic 
field may be sent together in a message or in separate messages, so that, for 
example, data from a vector instrument and a separate scalar instrument do not 
need to be combined into a single message to be sent. An entirely missing scalar 
element does not need to be sent at all. The arrays sent in a single message must 
all be the same length and contain only numbers or the value "null", which is used
to indicate a missing sample. Valid arrays are:

- "geomagneticFieldX": Magnetic field vector strength in nT, x component, geographic coordinates.
- "geomagneticFieldY": Magnetic field vector strength in nT, y component, geographic coordinates.
- "geomagneticFieldZ": Magnetic field vector strength in nT, z component, geographic coordinates.
- "geomagneticFieldH": Magnetic field vector strength in nT, in the horizontal plane along the magnetic meridian.
- "geomagneticFieldD": Angle between the magnetic vector and true north, in degrees of arc, positive east.
- "geomagneticFieldI": Angle between the magnetic vector and the horizontal, in degrees of arc, positive below the horizontal.
- "geomagneticFieldF": Geomagnetic field strength in nT, calculated from and consistent with XYZ or HDZ field elements.
- "geomagneticFieldS": Geomagnetic field strength in nT, measured by an independent scalar instrument.

Only arrays corresponding with the "elements-recorded" in the message topic may be used.

The optional extra metadata may be completely missing, or any part of parts may be included.
The purpose of this metadata is to allow the data provider to supply metadata values that the Intermagnet
data portal will use when creating IMF, IAGA-2002 and ImagCDF data files for users. The data portal
stores a metadata file for each day and publication level of data. Thus it is only neccessary
for a data provider to send one message per day / publication level, containing the optional metadata that
they require to be distributed with their data. Subsquent messages for the same day / publication level
do not require any optional metadata. If data provider's follow this advice, it is best
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

