# Report of meeting of GIN Subcommittee during INTERMAGNET Rio-de-Janeiro meeting, 7th and 8th November 2024

## Attendees
- Charles Blais (CB)
- Simon Flower (SF)
- Brendan Geels (BG)
- Virginie Maury (VM)

### Others mentioned in this report
- Roman Leonhardt (RL)
- Shun Imajo (SI)

## Review of action items from previous meeting
- [x] Online 2020 GWD.A5, Done: CB, All
  - Continue work on INTERMAGNET.github.io to remove all reference to intermagnet.org

- [x] Online 2020 GWD.A7, Done: CB
  - Point intermagnet.org to intermagnet.github.io NRCan to eventually follow up with SSC (central IT service) to change DNS CNAME of intermagnet.github.io so that the domain is still valid

- [ ] Online 2020 GWD.A9, Ongoing: SF, JF 	
  - Discussion to continue on the future of a web friendly format (JSON) for distributing data. Initial proposal of CovJSON needs a few adjustments. https://github.com/INTERMAGNET/wg-www-gins-data-formats/issues/7
  - ONGOING

- [ ] Online 2020, Ongoing: GWD.A10 CB, GWD
  - Start a guideline for doing technical notes in markdown on GitHub https://github.com/INTERMAGNET/wg-www-gins-data-formats/issues/2
 - ACTION: Mail to Charles suggesting it's completed

- [ ] Online 2020 GWD.A12, Not started: SF
  - Correct CDF files for leap second wg-www-gins-data-formats/issues/5. Once INTERMAGNET data is transferred from NRCan to BGS, BGS will correct CDF files for leap seconds.
  - ACTION: Request Stephan (via GitHub) to close the issue - https://github.com/INTERMAGNET/wg-www-gins-data-formats/issues/5

- [ ] Online 2020 GWD.A13, Not started: GWD
  - Add license information to IAGA2002 header and CDF. https://github.com/INTERMAGNET/wg-www-gins-data-formats/issues/1
  - ACTION: Request Charles (via GitHub) to close the issue

- [ ] Online 2020 GWD.A14, Ongoing: GWD
  - Continue the discussion on flagging geomagnetic data https://github.com/INTERMAGNET/wg-www-gins-data-formats/issues/3
  - ACTION: Request Charles, Roman and Virginie (via GitHub) to close the issue

- [x] Sopron 2023 GWD.A1, Done: RL
  - To make available documentation on implementation of MQTT.

- [x] Sopron 2023 GWD.A2, Done: SF (with help from RL, BH, VM, TR, SB)
  - To design and implement an MQTT receiver for the Edinburgh GIN and report on experience using it to receive INTERMAGNET data.

- [x] Sopron 2023 GWD.A3, Done: CB
  - To make available his Seedlink Docker image.

- [x] Sopron 2023 GWD.A4, Done: SF (with help from BG, CB)
  - To design and implement a Seedlink receiver for the Edinburgh GIN and report on experience using it to receive INTERMAGNET data.

- [ ] Sopron 2023 GWD.A5, Not started: SF, DC, RL, AL, AG, JM, JR
  - To recommend changes to the BLV file format to support automatic observation instruments.

- [ ] Sopron 2023 GWD.A6, Not started: David Boteler (with help from SF)
  - To take on renewal of the Memorandum of Understanding with the World Data System.
  - ACTION: Mail to David, to check on progress

## Use of MQTT for faster transport of data from observatories

A full description of this and the following two topics is in https://github.com/INTERMAGNET/wg-www-gins-data-formats/issues/14

### Report on MQTT transmissions

The Edinburgh GIN has been accepting data via MQTT since April 2024. Two institutes offered to take part in a test of the MQTT service: Royal Meteorological Institute (RMI) of Belgium and the Institute of Geophysics, Polish Academy of Science (IGPAS).
1-Minute data from two RMI observatories, DOU and MAB, were initially sent as test data, but following success of this trial, MQTT was made the primary transfer mechanism for these two observatories. 1-Second data from the IGPAS observatory BEL has been successfully sent as test data.

### Implementation of MQTT at Kyoto and Paris GINs

The aims of the changes describe below are to:

1. Allow observatories that are capable to use the fast MQTT transfer system.
2. Ensure that observatories that do not have the capability to use MQTT can continue transferring data in the same way that they do now.
3. To allow the Edinburgh GIN to stop providing an Rsync service for the other GINs.

#### Kyoto GIN

The Kyoto GIN manager was not able to attend the meeting. The subcommittee chair
will contact the Kyoto GIN manager to discuss implementation of these proposals.

**ACTION: SF to discuss MQTT impementation at the Kyoto GIN with SI.**

#### Paris GIN

The Paris GIN manager will investigate using MQTT for transfer of real-time data and will also look at using the Edinburgh GIN web service (https://gin-upload.bgs.ac.uk/GINFileUpload/Index.html) for non-real-time (e.g. quasi-definitive) data. 

**ACTION: VM to investigate new ways of transferring data to the Edinburgh GIN.**

### Changes to MQTT topic and payload formats

We discussed whether the current topic and payload formats (described here: https://github.com/INTERMAGNET/wg-www-gins-data-formats/tree/master/ImagMQTT) are suitable for our needs. We will make some changes to the current proposals.

The topic and payload description will be given the name Intermagnet MQTT Payload Format. The abberviation for this name is "IMPF".

The topic for MQTT messages is composed of the following elements:

```
<iaga-code>/<cadence>/<publication-level>
```

1. The \<cadence> element contains the data sample period as an ISO8601 duration. ISO8601 durations only allow time periods of 1-second and above. To ensure that the MQTT system can support data with higher sample rates, the \<cadence> element of the topic may contain either an ISO8601 duration or a sample rate in Hertz specified as an integer number with the suffix "hz", e.g. "1hz" for 1-second data.

2. A new element will be introduced at the start of the topic string, containing the short form of the topic/payload name. Including this in the topic allows different payload formats to be developed in the future and for the type of payload being sent to be identified from the topic string.

3. The "elementsRecorded" compulsory metadata item will be removed from the payload and added to the end of the topic string. This will allow for future developments where observatories wish to send multiple "streams" of data in different geomagnetic orientations and users wish to subscribe to one or more of these streams.

The new topic string is composed of the following elements:

```
impf/<iaga-code>/<cadence>/<publication-level>/<elements-recorded>
```

The only change to the payload is the removal of the "elementsRecorded" metadata field.

**ACTION: SF to update the MQTT documentation with changes to the topic and payload.**

We anticipate that incorporating support for this MQTT format into MagPy will help observatories to work with the format. We request that support is added to magPy for reading and writing MQTT payloads in the Intermagnet MQTT Payload Format. We also request that the IMPF JSON schema (https://github.com/INTERMAGNET/wg-www-gins-data-formats/blob/master/ImagMQTT/ImagMQTTSchema.json) is included in MagPy (once the planned changes have been implemented).

**ACTION: RL to add support for IMPF in MagPy.**

### Rationalisation of documentation

The documentation for MQTT (and Seedlink) will eventually need to be added to the Intermagnet Technical Manual. However, the MQTT and Seedlink proposals are not yet sufficiently mature to allow this. In the meantime there is a need for clear documentation to allow Intermagnet officers and institutes to start implementing these proposals. Work is needed to rationalise the current documentation into a single, authoritative place.

**ACTION: SF to rationalise MQTT and Seedlink documentation**

## Use of Seedlink for inter-GIN data transport (Canada, US)

The Edinburgh GIN has been accepting data via Seedlink since April 2024. 1-Minute and 1-second data from the Natural Resources Canada observatories, BLC and MEA,  has been successfully sent as test data. There has been a large gap in the data received this way because of a problem authorising network access at BGS following computer upgrades, but this problem has been resolved.

### Implementation at Natural Resources Canada

Real-time data from Canadian observatories is already available on a public Seedlink server. We will expand the test for transfer of Canadian data to include all observatories and then move to replace the current rsync transfers with Seedlink.

For non-real-time (e.q. quasi-definitive) data, Canada will investigate using the data transfer web service at the Edinburgh GIN (https://gin-upload.bgs.ac.uk/GINFileUpload/Index.html).

**ACTION: CB to investigate new ways of transferring data to the Edinburgh GIN.**

### Implementation at USGS

Real-time data is transferred within USGS using Seedlink and is close to being available to Intermagnet. USGS will make this data available to Intermagnet as soon as they are able. USGS also intend to look at MQTT as a replacement for the rsync transfer of non-real-time (e.g. quasi-definitive) data.

**ACTION: BG to investigate new ways of transferring data to the Edinburgh GIN.**

## Removal of Rsync for inter-GIN data transport (Canada, France, Japan, US)

BGS would like to remove the rsync service that GINs currently use to transfer data. The motivation for doing this is because of the difficulty in maintaining the rsync receiving software at BGS. 

The previous two topics have already discussed the means by which the rsync service will be replaced.

## Impact of including data without baselines on Intermagnet systems

There are discussions in other parts of this meeting about the possibility of allowing geomagnetic data without baselines to be added to Intermagnet data stores. We discussed this with a view to any technical problems that might result from doing this.

Possible technical problems raised are:

1. The Intermagnet data portal assumes all data sent to the GINs are full field magnetic values to enable conversion between different geomagnetic orientations. Data without a baseline would need to be marked so that the software doesn't attempt to convert in this way.

2. If the proposal includes publication of definitive data without baselines, the imcdview data viewer will need to be modified so that it does not allow conversion between different geomagnetic orientations for data without baselines.

3. If data from variometer networks is included, the number of available IAGA codes may be exceeded and we will need an alternative scheme for identifying recording stations.

There is an open issue on this subject if people wish to comment further: https://github.com/INTERMAGNET/wg-www-gins-data-formats/issues/16

## Review of issues on WWW-GIN-DF GitLab

There are a number of old issues in the GitHub issues area for this subcommittee. These will be reviewed to see which ones can be closed. See the issues here: https://github.com/INTERMAGNET/wg-www-gins-data-formats/issues

**ACTION: SF, CB, BG, VM to review GitHub issues.**

## Other business

We agreed to hold regular (e.g. every 3 or 6 month) online meetings.

**ACTION: SF to organise regular online meetings of the subcommittee.**

## Summary of actions

1. ACTION: SF to discuss MQTT impementation at the Kyoto GIN with SI.
1. ACTION: VM to investigate new ways of transferring data to the Edinburgh GIN.
1. ACTION: SF to update the MQTT documentation with changes to the topic and payload.
1. ACTION: RL to add support for IMPF in MagPy.
1. ACTION: SF to rationalise MQTT and Seedlink documentation
1. ACTION: CB to investigate new ways of transferring data to the Edinburgh GIN.
1. ACTION: BG to investigate new ways of transferring data to the Edinburgh GIN.
1. ACTION: SF, CB, BG, VM to review GitHub issues.
1. ACTION: SF to organise regular online meetings of the subcommittee.
