# Report of GIN Subcommittee meeting during INTERMAGNET Lisbon meeting, 8th and 9th September 2025

See the meeting agenda here: https://github.com/INTERMAGNET/wg-www-gins-data-formats/blob/master/Meeting_2025-09/MeetingAgenda.md.

## Attendees
- Charles Blais (CB)
- Simon Flower (SF)
- Brendan Geels (BG)
- Shun Imajo (SI)
- Virginie Maury (VM)

### Others mentioned in this report
- Stephan Bracke (SB)
- Roman Leonhardt (RL)
- Jürgen Matzka (JM)
- Chris Turbitt (CT)

## Review of action items from previous meetings

### Issues on GitHub

See GitHub issues here https://github.com/INTERMAGNET/wg-www-gins-data-formats/issues.

1. Issue https://github.com/INTERMAGNET/wg-www-gins-data-formats/issues/14 has been closed, as it has been superseded by a program of work that is being discussed at this meeting.
1. Issue https://github.com/INTERMAGNET/wg-www-gins-data-formats/issues/13 has been closed, as it has been superseded by a program of work that is being discussed at this meeting.
1. Issue https://github.com/INTERMAGNET/wg-www-gins-data-formats/issues/12 has been closed, as it has been completed and written up here: https://github.com/INTERMAGNET/wg-www-gins-data-formats/tree/master/ImagMQTT.
1. Issue https://github.com/INTERMAGNET/wg-www-gins-data-formats/issues/11 has been closed, as we were unsure what actions were being proposed.
1. Issue https://github.com/INTERMAGNET/wg-www-gins-data-formats/issues/10 has been closed, as we believe there is nothing further to add.
1. Issue https://github.com/INTERMAGNET/wg-www-gins-data-formats/issues/8 has been closed, as the work has been completed.
1. Issue https://github.com/INTERMAGNET/wg-www-gins-data-formats/issues/5 has been closed, as the CDF files distributed by Intermagnet now have correct leap seconds. The only remaining part of the issue was to set up an automated check for CDF leap second updates, but we have not been able to resolve this with the current software.

### Actions from the Intermagnet Rio meeting (November 2024)

See the actions from this meeting here: https://github.com/INTERMAGNET/wg-www-gins-data-formats/blob/master/Meeting_2024-11/GINSubcommitteeMeetingMinutes.md.

 1. [x] *SF to discuss MQTT impementation at the Kyoto GIN with SI*. This action has been superseded by a program of work that is being discussed at this meeting.
 1. [x] *VM to investigate new ways of transferring data to the Edinburgh GIN*. This action has been superseded by a program of work that is being discussed at this meeting.
 1. [x] *CB to investigate new ways of transferring data to the Edinburgh GIN*. This action has been superseded by a program of work that is being discussed at this meeting.
 1. [x] *BG to investigate new ways of transferring data to the Edinburgh GIN*. This action has been superseded by a program of work that is being discussed at this meeting.
 1. [x] *SF to update the MQTT documentation with changes to the topic and payload*. Updates have been made to the MQTT documentation
 1. [x] *SF to update BGS MQTT software and notify existing MQTT users of topic and payload changes*. Updates have been made to the software and users notified.
 1. [x] *RL to add support for IMPF in MagPy*. MagPy and MARTAS have been updated to include support for MQTT and its data formats.
 1. [x] *SF to rationalise MQTT and Seedlink documentation*.  This action has been superseded by a program of work that is being discussed at this meeting.
 1. [x] *SF, CB, BG, VM to review GitHub issues*. All GitHub issues were reviewed.
 1. [x] *SF to organise regular online meetings of the subcommittee*. An online meeting was held in March 2025.

## Progress with use of Seedlink for inter-GIN data transport (Canada, US)

Summary: It should be possible to complete the replacement of Rsync transfers from Canada and the US to the UK by the end of 2025.

### Canadian GIN (CB)

Work to transfer data between the Canadian and Edinburgh GINs using Seedlink is complete. All provisional data, except quasi-defintive data, is now being transferred using Seedlink. NRCan are not yet sending quasi-definitive data, but plan to do so using the Edinburgh GIN data subsmission web service.

NRCan are looking are looking into a technology called nats.io, in particular the jetstream module, which will allow them to use MQTT. They may think about moving from Seedlink to MQTT in the future. They are thinking ahead about how to distribute data to clients in real-time and MQTT is one option for this. Potential clients for this service include those with an interest in GIC.

### US GIN (BG)

The US currently have just a few observatories available via Seedlink, but will soon be able to send all observatories (when the Seedlink ring size is increased). We should be able to start test Seedlink transfers between the US and Edinburgh GINs after this meeting. Data compression and the requirement to fill a fixed length buffer mean that data can be delayed - they are looking at ways around this.
   
USGS are investigating MQTT for internal data transport. This work will require a new database. The work is partly motivated by network restrictions.

## Progress with use of MQTT for inter-GIN data transport (France, Japan)

Summary: It should be possible to complete the replacement of Rsync transfers from France and Japan to the UK by the end of 2026.

### French GIN (VM)

The French GIN requires a full upgrade, including moving from ftp to sftp. This is a major piece of work that has yet to be started. Enabling MQTT data transfer will be part of this upgrade. The work done by RL to support MQTT in MagPy and MARTAS may be useful here.

### Japanese GIN (SI)

A report on progress was provided and can be seen here: https://github.com/INTERMAGNET/wg-www-gins-data-formats/blob/master/Meeting_2025-09/mqtt_report_kyoto_20250907.pdf

## Use of MQTT for faster transport of data from observatories

Six observatories are using MQTT to send data to the Edinburgh GIN. They are: BEL, DOU, HLP, HRN, MAB, VAL.

## Other discussions

CB talked about the need to enable the user community to create their own tools to work with our data.

SF discussed the need to encourage observatories to send data in real-time - providing the technology for real-time transfer will not realise any benefits until observatories start using it.

### The Intermagnet data protal

There were discussions during the plenary meeting about issues relating to the data portal:

1. Users would like to see an information "(i)" icon on all labels on all pages to make it clearer that help information is available.
1. JM sent email to SF (19/08/2025) describing problems downloading data, wherby the downloaded data contained an incorrect scalar F value: When selecting "calculated components X Y Z F(scalar)" we get recorded F. For example peg20250802vsec.sec where we get calculated F and not recorded F in the IAGA-2002 downloaded file (and I would expect recorded F as I selected recorded components). Investigate this issue and fix any associated problems.
1. There is confusion about the view/download button - it doesn't download! Find a better way to lay out this page.
1. SB requested that we add acknowledgement text to data download scripts (in the same way that it is currently added to IAGA-2002 and CDF data files).

There was also discussion about whether all data in the portal should be full-field data. The conclusion was that it should be, so the current restriction whereby only recorded components are provided for reported data through the HAPI interface can be removed.

SF had a list of observatories that appear to be sending reported data without a baseline.   

## Actions

- BG, SF: Complete implementation of Seedlink data transfer from Golden -> Edinburgh GIN
- SI, SF: Complete implementation of MQTT data transfer from Kyoto -> Edinburgh GIN
- VM: Redesign Paris GIN
- VM, SF: Implement MQTT data transfer from Paris -> Edinburgh GIN
- SF: Implement the changes that were discussed to the Intermagnet data portal
- SF: Send list of observatories transmitting variometer data to CT
- SF: Organise an online GIN managers meeting

