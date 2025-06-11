It is envisaged that this text would be "slotted" in to the current Intermagnet technical manual
in section 6. The headings have been created with that in mind. This paragraph should be removed
before inserting the text into the technical manual. The text includes links to an external file
called "ImagMQTTSchema.json" which must be available in the same folder as the file holding this
text.


Submission via MQTT
-------------------

For the best real-time performance (and least delay) data can be submitted to
Intermagnet using MQTT. Using MQTT there is a very small delay (typically less
than a second) between an observatory submitting data and the data becoming
available on the Intermagnet data portal. Delays in data are then mainly due
to the frequency at which observatories transmit data. Observatories are 
encourged to transmit 1-minute data as soon as it is recorded and 1-second
data within 10 seconds of recording.

MQTT (Message Queuing Telemetry Transport) is a messaging protocol that enables 
communication between devices in the Internet of Things. To send messages over
MQTT you use software that conforms to the MQTT protocol - this software is
responsible for delivering your data to Intermagnet. One of the central
concepts in MQTT is that of the "broker". A broker receives messages from "publishers"
and makes them available to "subscribers". An observatory will publish data to a broker
that Intermagnet manages (and Intermagnet will subscribe to the broker in order to receive
the messages observatories send).

There are a number of suppliers of MQTT software, both commercial and free. There are
interfaces to most popular languages as well as standalone commands that can be
inegrated into scripts or schedulers (such a Unix cron). For standalone MQTT publishing
and subscription programs (as well as broker software) people in the observatory 
community have succesfully used Eclipse Mosquito MQTT (https://mosquitto.org/), which is 
free software. Binary packages are available for Windows, Linux and Mac. 
Eclipse Mosquitto also includes a library that can publish and subscribe messages from
programs written in the C language. For Python and Java programmers, the Paho project 
(https://eclipse.dev/paho/) offers a library that can be easily added to your programs (and
Paho also includes a C library, with other langauge interfaces being developed). 

MQTT at the Edinburgh GIN
`````````````````````````

Public MQTT brokers run at the Edinburgh GIN at the following Internet addresses:

- gin-mqtt.bgs.ac.uk - main Intermagnet/BGS MQTT service
- gin-mqtt-staging.bgs.ac.uk - development Intermagnet/BGS MQTT service

Access to MQTT uses TLS, to ensure that all traffic is securely encrypted. 
Connections to these services are received on the default MQTT TLS port, port 8883.
All connections to these servers require authentication and a username and
password will be set up for each observatory. Be sure to use these in a way that
ensures that any user can connect only once at a time to the brokers, as the
brokers are configured to only allow a single connection per user (and to
log off any previously existing connections).

MQTT at the Kyoto GIN
`````````````````````

MQTT at the Paris GIN
`````````````````````

Intermagnet MQTT payload format
```````````````````````````````

Intermagnet MQTT messages are formatted in JSON. A [JSON schema](ImagMQTTSchema.json)
describes the valid contents of an MQTT message. Messages must consist
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
- "geomagneticFieldD": Angle between the magnetic vector and true north, in minutes of arc, positive east.
- "geomagneticFieldI": Angle between the magnetic vector and the horizontal, in minutes of arc, positive below the horizontal.
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

Example IMPF data
`````````````````

The first example is a minimum viable data file for 1-minute data. A single 
3-component sample is presented along with mandatory metadata::

    {
        "startDate": "2023-01-01T00:00",
        "geomagneticFieldX": [ 17595.02, null, 17594.99 ],
        "geomagneticFieldY": [ -329.19, -329.18, -329.21 ],
        "geomagneticFieldZ": [ 46702.70, 46703.01, 46703.24 ]
    }


An expanded example shows how to add "comment" metadata, to set the "comments" 
section when the data is distributed in IAGA-2002 format. This example also 
shows how the startDate should be modified for 1-second data::

    {
        "startDate": "2023-01-01T00:00:00",
        "comments": [ "This data file was created using INTERMAGNET data",
                      "from the Edinburgh GIN. These data were acquired",
                      "from an INTERMAGNET quasi-def data file.",
                      "Final data will be available on the INTERMAGNET DVD",
                      "Go to www.intermagnet.org for details on obtaining this product.",
                      "CONDITIONS OF USE: The conditions of use for data provided",
                      "through INTERMAGNET and acknowledgement templates can be found",
                      "at www.intermagnet.org" ],
        "geomagneticFieldS": [ 49000.00, 49000.21, 49000.34 ]
    }

Intermagnet MQTT topics
```````````````````````

Topics in MQTT are strings used to identify and route messages. Topics allow
publishers to identify messages and subscribers to choose which types of message
to receive. Topics for the Intermagnet MQTT service have been designed to allow
the contents of the message to be easily identified. Observatories publishing data 
through the Intermagnet MQTT service must use the topic::

    impf/<iaga-code>/<cadence>/<publication-level>/<elements-recorded>

Where:

- "impf" stands for Intermagnet MQTT Payload Format and is included in the topic
  to allow alternative topic and payload formats to be used on the same MQTT
  brokers in the future.
- "iaga-code" is the IAGA registered code of the observatory sending data.
- "cadence" is the sample period for the data as an ISO8601 duration (for data
  with sampling rate of 1Hz or below) or the sample rate with the suffix "hz" (for
  data with sampling rate of 1Hz or above). Valid cadences are:
  - "pt1s" or "1hz" for 1-second data.
  - "pt1m" for 1-minute data.
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
would be::

    impf/esk/pt1m/1/hdzs

The topic for Lerwick observatory's 1-second quasi-definitive XYZS data would be either of the following::

    impf/ler/pt1s/3/xyzs
    impf/ler/1hz/3/xyzs

MQTT Quality of Service
```````````````````````

When publishing and subscribing to MQTT, one of the parameters that needs to be set is the
"quality of service" (QoS). For a description of QoS see here: 
https://www.hivemq.com/blog/mqtt-essentials-part-6-mqtt-quality-of-service-levels/.

The Edinburgh GIN will subscribe to the MQTT broker with a QoS of 2. Observatories
are recommended to publish with a QoS of 1, which reduces the overhead needed to manage
the message stream (since the lower of the two QoS levels is used between publisher and
subsriber). However, if there is a reason why it's important to guarantee that messages
are delivered in the same order they are sent, observatories can publish using a QoS of 2.

To enable QoS level 2 and to ensure messages are not missed, the Edinburgh GIN
subscribes to the MQTT broker with a 
[persistant session](https://www.hivemq.com/blog/mqtt-essentials-part-7-persistent-session-queuing-messages/).

Importance of the MQTT Client ID
````````````````````````````````

In MQTT, publication and subscription is associated with the subscriber's and publisher's client ID,
not the username. Only one client ID may be connected to an MQTT broker at at time. If a duplicate
client ID attempts to connect to a broker, the broker will disconnect the earlier connection. For these
reasons it is important that client IDs are selected so that there can never be any duplicate IDs.

The MQTT broker allows the username (used in authenticating with the broker) to be used as the
client ID. The only way to enforce unique client IDs is to allocate unique usernames to each
client (ie each observatory) and force clients to use the username as their client ID. This is
the approach used by the Intermagnet MQTT service.

MQTT Authentication and authorization
`````````````````````````````````````

Each observatory wishing to send data will be assigned connection details that will be 
needed to publish data on the Intermagnet MQTT service:

- A publication username. The username will be unique to the observatory and should not be shared.
  This username is used for publishing data.
- A publication password. The publication password is linked to the publication username.
- A subscription username. The username will be unique to the observatory and should not be shared.
  This username is used for subscribing to data, to allow an observatry to check that its
  data is being received.
- A subscription password. The subscription password is linked to the subscription username.

The usernames given to each observatory will define which topics (and so which observatories)
they can publish and subscribe to.

An observatory will be allowed to subscribe to the topics that it can publish to. Because
the client ID (specified by the username) can only connect once to a broker, it is
not possible to use one username to publish and subscribe at the same time. The username 
assigned for publication must be used only for publishing. A second username and password 
allows subscription at the same time as publication.

From a client perspective it isn’t easy to know if MQTT access control is being applied, as restrictions 
aren’t notified to the client (at least in MQTT v3.1.1). The way around this for a client wanting to
verify successful publication of data is to subscribe to a topic as well publishing and check whether 
any published messages are received through the subscription.

Secure MQTT transport
`````````````````````

Only secure (TLS) connections will be accepted by the Intermagnet MQTT service. Open
(unecrypted) connections expose the authentication and authorization credentials used
to connect to the service, thereby risking publication of data from unauthorized sources,
and so will not be accepted. The default port (8883) is used for MQTT over TLS.
