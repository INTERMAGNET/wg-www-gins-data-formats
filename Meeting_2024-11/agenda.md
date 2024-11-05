# Agenda for GIN subcommittee meeting, 7th and 8th November 2024 #

1. Review of action items from previous meetings:
   - [ ] Online 2020 GWD.A5, Ongoing: CB, All
     - Continue work on INTERMAGNET.github.io to remove all reference to intermagnet.org
   - [ ] Online 2020 GWD.A7, Ongoing: CB
     - Point intermagnet.org to intermagnet.github.io NRCan to eventually follow up with SSC (central IT service) to change DNS CNAME of intermagnet.github.io so that the domain is still valid
   - [ ] Online 2020 GWD.A9, Ongoing: SF, JF 	
     - Discussion to continue on the future of a web friendly format (JSON) for distributing data. Initial proposal of CovJSON needs a few adjustments. https://github.com/INTERMAGNET/wg-www-gins-data-formats/issues/7
   - [ ] Online 2020, Ongoing: GWD.A10 CB, GWD
     - Start a guideline for doing technical notes in markdown on GitHub https://github.com/INTERMAGNET/wg-www-gins-data-formats/issues/2
   - [ ] Online 2020 GWD.A12, Not started: SF
     - Correct CDF files for leap second wg-www-gins-data-formats/issues/5. Once INTERMAGNET data is transferred from NRCan to BGS, BGS will correct CDF files for leap seconds.
   - [ ] Online 2020 GWD.A13, Not started: GWD
     - Add license information to IAGA2002 header and CDF. https://github.com/INTERMAGNET/wg-www-gins-data-formats/issues/1 
   - [ ] Online 2020 GWD.A14, Ongoing: GWD
     - Continue the discussion on flagging geomagnetic data https://github.com/INTERMAGNET/wg-www-gins-data-formats/issues/3
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
2. Use of MQTT for faster transport of data from observatories
   - Report on test with DOU and MAB minute data (main transmission), also BEL second data (test transmission)
   - Support at French and Japanese GINs
   - Recommendations for the future
3. Use of Seedlink for inter-GIN data transport (Canada, US)
   - Report on test with BLC and MEA minute and second data (test trasnmission)
   - Recommendations for the future
4. Removal of Rsync for inter-GIN data transport (Canada, France, Japan, US)
5. Review of issues on WWW-GIN-DF GitLab: https://github.com/INTERMAGNET/wg-www-gins-data-formats/issues

A full description of agenda items 2 to 4 is in https://github.com/INTERMAGNET/wg-www-gins-data-formats/issues/14
