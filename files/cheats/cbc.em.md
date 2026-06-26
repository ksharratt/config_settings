# cbc em notes

## issues

### EM containers fail to restart

.env file docker GID is being overwritten during `configure.yml`

dot_env_template_path_dest: "{{ em_vendor_artifacts_dest_dir }}/artifacts/compose-files/.env"
em_vendor_artifacts_dest_dir: "/var/em/{{ group_names | select('match', 'Blueprint.+') | first }}/"

from .env file

    ### Others
    # the Docker group id is collected and set automatically by the script set_docker_group_id,
    # so don't change it manually
    # the default initial value is 4321, when set to that number it will be retrieved again
    DOCKER_GROUP_ID=4321

set_docker_group_id

    [root@pxy9-em1-cbc-0001 em-scripts]# pwd
    /var/em/Blueprint_5_0_0_1/artifacts/em-scripts

manually check the GID

    [root@pxy9-em1-cbc-0001 compose-files]# stat -c '%g' /var/run/docker.sock
    992
