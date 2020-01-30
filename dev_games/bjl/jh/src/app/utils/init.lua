package.loaded["app.utils."..device.platform] = nil
package.loaded["app.utils.Device"] = nil
package.loaded["app.utils.Utils"] = nil
package.loaded["app.utils.Md5"] = nil

require("app.utils."..device.platform)
require("app.utils.Device")
require("app.utils.Utils")
Md5 = require("app.utils.Md5")