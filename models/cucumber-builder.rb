require 'term/ansicolor'

class CucumberBuilder < Jenkins::Tasks::Builder
    include Term::ANSIColor

    attr_accessor :enabled, :cucumber_profile, :browser, :display, :color_output, :cucumber_dir, :verbosity

    display_name "Run cucumber tests"

    def initialize(attrs = {})
        @enabled = attrs["enabled"]
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

        if @enabled == true

            ruby_version = env['cucumber_ruby_version'] || default_ruby_version
            workspace = build.send(:native).workspace.to_s

            if @color_output == true
                listener.info magenta("runing cucumber tests ... ")
                listener.info "#{magenta("ruby_version:")} #{blue("#{ruby_version}")}"
                listener.info "#{magenta("cucumber profile:")} #{blue("#{@cucumber_profile}")}"
            else
                listener.info "runing cucumber tests ... "
                listener.info "ruby_version: #{ruby_version}"                
                listener.info "cucumber profile: #{@cucumber_profile}"
            end

            cmd = []
            cmd << "export LC_ALL=#{env['LC_ALL']}" unless ( env['LC_ALL'].nil? || env['LC_ALL'].empty? )
            cmd << "source #{env['HOME']}/.rvm/scripts/rvm"
            cmd << "export http_proxy=#{env['http_proxy']}" unless (env['http_proxy'].nil? ||  env['http_proxy'].empty?)
            cmd << "export https_proxy=#{env['http_proxy']}" unless (env['http_proxy'].nil? ||  env['http_proxy'].empty?)

            unless @cucumber_dir.nil? || @cucumber_dir.empty? 
                listener.info (@color_output == true) ? "#{magenta("runing from")} #{blue("#{cucumber_dir}")}" : "runing from #{cucumber_dir}"
                cmd << "cd #{workspace}/#{@cucumber_dir}"  
            else
                listener.info (@color_output == true) ? "#{magenta("directory:")} #{blue("default")}" : "directory: default"
                cmd << "cd #{workspace}"
            end
            
            cmd << "rvm use ruby #{ruby_version}"
            
            if @verbosity == true
                cmd << "bundle"
            else
                cmd << "bundle --quiet"
            end

            display = ''
            display = "DISPLAY=#{@display}" unless @display.nil? || @display.empty?    
            cmd << "bundle exec cucumber -p #{@cucumber_profile} -c no_proxy=127.0.0.1 browser=#{@browser} #{display} #{@color_output == true ? '--color' : '--no-color'}"
            build.abort if launcher.execute("bash", "-c", cmd.join(' && '), { :out => listener } ) != 0
        end

    end

end


