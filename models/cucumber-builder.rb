class CucumberBuilder < Jenkins::Tasks::Builder

    attr_accessor :enabled, :cucumber_profile, :browser, :display, :color_output, :test_path

    display_name "Run cucumber tests"

    def initialize(attrs = {})
        @enabled = attrs["enabled"]
        @cucumber_profile = attrs["cucumber_profile"]
        @browser = attrs["browser"] || 'chrome'
        @display = attrs["display"]
        @color_output = attrs["color_output"]
        @test_path = attrs["test_path"]
    end

    def prebuild(build, listener)
    end

    def default_ruby_version
        '1.8.7'
    end
    def perform(build, launcher, listener)

        env = build.native.getEnvironment()

        if @enabled == true

            workspace = build.send(:native).workspace.to_s
            listener.info "cucumber profile: #{@cucumber_profile}"
            listener.info "running cucumber tests ... "

            test_pass_ok = true
            ruby_version = env['cucumber_ruby_version'] || default_ruby_version
            listener.info "ruby_version: #{ruby_version}"                

            if ! @test_path.nil?
                listener.info "run #{@test_path} tests"
                cmd = []
                cmd << "export LC_ALL=#{env['LC_ALL']}" unless ( env['LC_ALL'].nil? || env['LC_ALL'].empty? )
                cmd << "source #{env['HOME']}/.rvm/scripts/rvm"
                cmd << "export http_proxy=#{env['http_proxy']}" unless (env['http_proxy'].nil? ||  env['http_proxy'].empty?)
                cmd << "export https_proxy=#{env['http_proxy']}" unless (env['http_proxy'].nil? ||  env['http_proxy'].empty?)
                cmd << "cd #{workspace}/#{@test_path}"
                cmd << "rvm use ruby #{ruby_version}"
                cmd << "bundle"
                display = ''
                display = "DISPLAY=#{@display}" unless @display.nil? || @display.empty?    
                cmd << "bundle exec cucumber -p #{@cucumber_profile} -c no_proxy=127.0.0.1 browser=#{@browser} #{display} #{@color_output == true ? '--color' : '--no-color'}"
                test_pass_ok = false if launcher.execute("bash", "-c", cmd.join(' && '), { :out => listener } ) != 0
            else 
                listener.info "run tests"
                cmd = []
                cmd << "export LC_ALL=#{env['LC_ALL']}" unless ( env['LC_ALL'].nil? || env['LC_ALL'].empty? )
                cmd << "source #{env['HOME']}/.rvm/scripts/rvm"
                cmd << "export http_proxy=#{env['http_proxy']}" unless (env['http_proxy'].nil? ||  env['http_proxy'].empty?)
                cmd << "export https_proxy=#{env['http_proxy']}" unless (env['http_proxy'].nil? ||  env['http_proxy'].empty?)
                cmd << "rvm use ruby #{ruby_version}"
                cmd << "bundle"
                display = ''
                display = "DISPLAY=#{@display}" unless @display.nil? || @display.empty?    
                cmd << "bundle exec cucumber -p #{@cucumber_profile} -c no_proxy=127.0.0.1 browser=#{@browser} #{display} #{@color_output == true ? '--color' : '--no-color'}"
                test_pass_ok = false if launcher.execute("bash", "-c", cmd.join(' && '), { :out => listener } ) != 0
            end

            build.abort if test_pass_ok == false

        end

    end

end


