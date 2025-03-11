# Report of online meeting of GIN Subcommittee, 7th March 2025

## Attendees
- Charles Blais (CB)
- Simon Flower (SF)
- Shun Imajo (SI)
- Brendan Geels (BG)
- Jürgen Matzka (JM)
- Virginie Maury (VM)

### Others mentioned in this report
- Roman Leonhardt (RL)

## Agenda
1. Progress on using MQTT at Kyoto and Paris
2. What do we need to do to enable Seedlink transfers from Golden and Ottawa to Edinburgh?
3. Timetable for removal of Rsync transfers between GINs
4. Any other business (in particular, any updates on items from the Rio meeting - https://github.com/INTERMAGNET/wg-www-gins-data-formats/blob/master/Meeting_2024-11/GINSubcommitteeMeetingMinutes.md)

## Progress on using MQTT at Kyoto and Paris

SI presented a [report from Kyoto](mqtt_report_kyoto_20250307.pdf) showing good progress and with the expectation of a working system for MQTT transfer by the end of this year.

VM reported that she is working full time on replacing a BCMT server following cyber attacks. She has another high priority project following that, but should be able to start work on MQTT in the summer or autumn. Nobody else is available to work on any of these projects and she has no IT support. CB asked whether software being developed ay Kyoto could be reused in Paris, VM is hopeful this could be useful and SI is happy to share the work they are doing.

SF will contact Roman Leonhardt to find out whether MagPY can convert between the Intermagnet MQTT format and IAGA-2002 (a key requirement for an MQTT service at Kyoto and Paris).

## Seedlink transfers from Golden and Ottawa to Edinburgh

BG reported that USGS are transfering observatory data internally in miniseed format, but need to set up a public ringserver to make the data available. They are interested in MQTT, but will be using miniseed for the foreseable future.

BG states that MQTT allows for more secure operations:
 - data is pushed rather than pulled
 - no problems with changing IP adresses

CB said that all Canadian Intermagnet provisional observatory data is available from NRCan Seedlink servers. SF will set up the Seedlink receiver at the Edinburgh GIN to receive data from all these observatories and, if the transfers are successful, switch to using this as the main method of transferring data from Ottawa. This will cover provisional data, but another transfer method is needed for quasi-definitive data, which is sent "manually" rather than as part of automatic processing. SF said that quasi-definitive data could be sent via email or using the data delivery web service at the Edinburgh GIN. SF will contact David Calp at NRCan to discuss this, copying CB into the discussions.

NRCan have two Seedlink servers available (for the purposes of redundancy):

- data1.earthquakescanada.nrcan.gc.ca -> 132.156.41.208
- data2.earthquakescanada.nrcan.gc.ca -> 139.142.67.8

SF will send details of the BGS web service used to upload data to the Edinburgh GIN to both Brendan and Charles (a possible mechanism for transferring quasi-definitive data to the Edinburgh GIN).

## Timetable for removal of Rsync transfers between GINs

Given the discussions on implementation of MQTT and Seedlink for transfer of provisional data, it seems reasonable to plan for removal of the rsync service at BGS in early to mid 2026.

## Any other business

CB raised the question of how Intermagnet distributes real-time data to users. Are users interested and able to use the streaming protocols we are developing and are we able to supply data in this way? This led to further discussion about who are our users and how we know what they want - we have very little knowledge about this. We also need to consider the security aspects of any potential solutions. We will keep this issue on our agenda.

SF will set up another meeting date for late spring / early summer 2025.
