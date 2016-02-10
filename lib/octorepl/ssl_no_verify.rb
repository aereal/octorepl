require 'openssl'

original_verbose = $VERBOSE
$VERBOSE = nil # Supress warnings
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
$VERBOSE = original_verbose
