# community based trail testing and validation commands

    [root@cjy9-cbc2-cbc-0001 ~]# date; cbc msg list | grep 06-19

    [root@cjy9-cbc2-cbc-0001 ~]# cbc msg report 2870


# cbe alert messages use a seperate IO to cbc

ID string

    <identifier>CTH_NEMA.1643.1643

Commands

    Shows CBE Alert message xml coming in
    [root@cjy9-capgw2-cbc-0001 logs]# pwd
    
    /data/pwp_data/logs
    
    [root@cjy9-capgw2-cbc-0001 logs]# less +G pwp-input-cap.log

    Shows CBC msg alert and polygon 
    [root@cjy9-cbc2-cbc-0001 logs]# less +G cbegateway.log 
    [root@cjy9-cbc2-cbc-0001 logs]# pwd
    /data/cbegateway_data/logs
