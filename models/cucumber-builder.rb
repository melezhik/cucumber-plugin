require 'simple/console'

class CucumberBuilder < Jenkins::Tasks::Builder

    attr_accessor :enabled, :cucumber_profile, :ignore_failures, :browser
    attr_accessor :display, :color_output, :cucumber_dir, :verbosity

    display_name "Run cucumber tests"

    def initialize(attrs = {})
        @enabled = attrs["enabled"]
        @ignore_failures = attrs["ignore_failures"]
        @cucumber_profile = attrs["cucumber_profile"]
        @browser = attrs["browser"] || 'chrome'
        @display = attrs["display"]
        @color_output = attrs["color_output"]
        @cucumber_dir = attrs["cucumber_dir"]
        @verbosity = attrs["verbosity"]
    end

    def prebuild(build, listener)
    end

    def default_ruby_version
        '1.8.7'
    end

    def perform(build, launcher, listener)

        env = build.native.getEnvironment()
        sc = Simple::Console.new(:color_output => @color_output)        

        if @enabled == true

            ruby_version = env['cucumber_ruby_version'] || default_ruby_version
            workspace = build.send(:native).workspace.to_s

            if @cucumber_dir.nil? || @cucumber_dir.empty? 
                cucumber_dir = workspace
            else 
                cucumber_dir = "#{workspace}/#{@cucumber_dir}"
            end

            listener.info sc.info('runing cucumber tests', :title => 'stage')
            listener.info sc.info(ruby_version, :title => 'ruby_version')
            listener.info sc.info(@cucumber_profile, :title => 'cucumber profile')
            listener.info sc.info(File.basename(cucumber_dir), :title => 'directory')

            cmd = []
            cmd << "export LC_ALL=#{env['LC_ALL']}" unless ( env['LC_ALL'].nil? || env['LC_ALL'].empty? )
            cmd << "source #{env['HOME']}/.rvm/scripts/rvm"
            cmd << "export http_proxy=#{env['http_proxy']}" unless (env['http_proxy'].nil? ||  env['http_proxy'].empty?)
            cmd << "export https_proxy=#{env['http_proxy']}" unless (env['http_proxy'].nil? ||  env['http_proxy'].empty?)
            cmd << "cd #{cucumber_dir}"
            cmd << "rvm use ruby #{ruby_version}"
            
            if @verbosity == true
                cmd << "bundle"
            else
                cmd << "bundle --quiet"
            end

            display = ''
            display = "DISPLAY=#{@display}" unless @display.nil? || @display.empty?    
            cmd << "bundle exec cucumber -p #{@cucumber_profile} -c no_proxy=#{env['no_proxy']} browser=#{@browser} #{display} #{@color_output == true ? '--color' : '--no-color'}"
            
            test_run_status = launcher.execute("bash", "-c", cmd.join(' && '), { :out => listener } )
            if test_run_status != 0 and @ignore_failures == false
              build.abort 
            elsif test_run_status != 0 and @ignore_failures == true
              listener.info 'tests failed but because of "ignore_failures" is on, we continue here'
              launcher.execute("bash", "-c", "touch #{workspace}/test.fail", { :out => listener } )
            else
              listener.info 'tests are passed'
            end
            
        end

    end

end


