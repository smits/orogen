$LOAD_PATH.unshift File.expand_path('../lib', File.dirname(__FILE__))
require 'orogen/test'

class TC_GenerationTypegen < Test::Unit::TestCase
    include Orocos::Generation::Test
    TEST_DATA_DIR = File.join( TEST_DIR, 'data' )

    def test_generate_and_install
        build_typegen "simple", "modules/typekit_simple/simple.h", []
    end

    def test_check_uptodate
        build_typegen "simple", ["modules/typekit_simple/simple.h"], []

        in_wc("typekit_output") do
            # Touch the orogen file
            FileUtils.touch "types/simple.h"

            # First check that the user is forbidden to go on with building
            Dir.chdir("build") do
                assert !system("make")
            end
            # Now, verify that we can run make regen
            Dir.chdir("build") do
                assert system("make", "regen")
                assert system("make")
            end
        end
    end
end

