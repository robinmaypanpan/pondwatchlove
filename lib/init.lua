-- Initializes library access
package.path = package.path .. ";lib/?.lua"

-- Should require remaining files
require('table')
require('math')
require('string')