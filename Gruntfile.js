'use strict';

module.exports = function(grunt) {

    grunt.initConfig({
      /** Read package.json **/
      pkg: grunt.file.readJSON('package.json'),
      /** aws credentials **/
      aws: grunt.file.readJSON('aws.json'),
      /** Shell utils **/
      shell: {
        /** Upload using deb-s3 **/
        upload: {
            command: "deb-s3 upload --bucket get.elastrix.io --prefix ubuntu tmp/*_<%= pkg.version %>-1_amd64.deb --access-key-id=<%= aws.accessKeyId %> --secret-access-key=<%= aws.secretAccessKey %> --sign=4C596627"
        },
        /** Setup your system to install using apt **/
        setup_apt_repo: {
            command: "echo deb http://get.elastrix.io/ubuntu stable main > /etc/apt/sources.list.d/elastrix.list && apt-key adv --keyserver hkp://keyserver.ubuntu.com:11371 --recv-keys 4C596627 && apt-get update"
        },
        clean: {
          command: "rm -fR bin/* tmp/*"
        },
        chmod: {
          command: "chmod a+x bin/elastrix"
        }
      },
      /** create debian packages **/
      debian_package: {
          /** default / global options **/
          options: {
            maintainer: {
                    name: "Elastrix",
                    email: "admin@elastrix.io"
                }
          },
          /** Ghost on NGINX **/
          elastrix: {
            options: {
                name: "elastrix",
                postfix: "",
                short_description: "Elastrix command line tools",
                long_description: "Elastrix command line tools for Elastrix cloud servers on debian based linux platforms",
                version: "<%= pkg.version %>",
                build_number: "1",
                target_architecture: "amd64",
                category: "devel",
                links:[
                  {
                    source:'/usr/sbin/elx',
                    target:'/usr/sbin/elastrix'
                  }
                ],
                dependencies: "curl"
            },
            files: [
                {
                    expand: true,
                    cwd: 'bin/', 
                    src: [
                        'elastrix'
                    ],
                    dest: '/usr/sbin'
                },
                {
                    expand: true,
                    cwd: 'bin/', 
                    src: [
                        '.elx'
                    ],
                    dest: '~/'
                }
            ]
          }
      },
      concat: {
          options: {
            separator: '\n\n##\n# module\n##\n\n',
          },
          dist: {
            src: [
                'src/app', 
                'src/lib/*.sh', 
                'src/modules/webmin.sh',
                'src/modules/nginx.sh',
                'src/modules/apache.sh',
                'src/modules/mysql.sh',
                'src/modules/wordpress.sh',
                'src/modules/ghost.sh',
                'src/modules/kurento.sh',
                'src/modules/monit.sh',
                'src/modules/ssl.sh',
                'src/modules/parse.sh',
                'src/modules/setup.sh',
                'src/main.sh'
            ],
            dest: 'bin/elastrix',
          },
        },

      copy: {
        main: {
          files: [
            {expand: false, src: ['src/config.sh'], dest: 'bin/.elx', filter: 'isFile'}
          ],
        },
      },
    });

    grunt.loadNpmTasks('grunt-debian-package');
    grunt.loadNpmTasks('grunt-shell');
    grunt.loadNpmTasks('grunt-contrib-concat');
    grunt.loadNpmTasks('grunt-contrib-copy');

    grunt.registerTask('build', ['shell:clean','concat','copy','debian_package:elastrix','shell:chmod']);
    grunt.registerTask('clean', ['shell:clean']); 

    grunt.registerTask('upload', ['shell:upload']);
    grunt.registerTask('setup-apt-repo', ['shell:setup_apt_repo'])

}