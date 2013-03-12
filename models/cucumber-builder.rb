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

    def formatted_text(title,message)
        if @color_output == true
            string = "#{black(red(bold("#{title}")))} #{bold(black(blue("#{message}")))}"
        else
            string = "#{title} #{message}"
        end
        string
    end

    def perform(build, launcher, listener)

        env = build.native.getEnvironment()

        if @enabled == true

            ruby_version = env['cucumber_ruby_version'] || default_ruby_version
            workspace = build.send(:native).workspace.to_s

            if @cucumber_dir.nil? || @cucumber_dir.empty? 
                cucumber_dir = workspace
            else 
                cucumber_dir = "#{workspace}/#{@cucumber_dir}"
            end

            if @color_output == true
                listener.info bold("runing cucumber tests")
            else
                listener.info "runing cucumber tests"
            end
            listener.info formatted_text('stage', 'runing cucumber tests')
            listener.info formatted_text('ruby_version:', ruby_version)
            listener.info formatted_text('cucumber profile:', @cucumber_profile)
            listener.info formatted_text('directory:', File.basename(cucumber_dir))

            cmd = []
            cmd << "export LC_ALL=#{env['LC_ALL']}" unless ( env['LC_ALL'].nil? || env['LC_ALL'].empty? )
            cmd << "source #{env['HOME']}/.rvm/scripts/rvm"
            cmd << "export http_proxy=#{env['http_proxy']}" unless (env['http_proxy'].nil? ||  env['http_proxy'].empty?)
            cmd << "export https_proxy=#{env['http_proxy']}" unless (env['http_proxy'].nil? ||  env['http_proxy'].empty?)
            cmd << "cd 1#{cucumber_dir}"
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


