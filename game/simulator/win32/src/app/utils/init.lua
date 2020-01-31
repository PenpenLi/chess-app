package.loaded["app.utils."..device.platform] = nil
package.loaded["app.utils.Device"] = nil
package.loaded["app.utils.Utils"] = nil
package.loaded["app.utils.Md5"] = nil
package.loaded["app.utils.ImageUtils"] = nil
package.loaded["app.utils.NodeEx"] = nil

require("app.utils."..device.platform)
require("app.utils.Device")
require("app.utils.Utils")
Md5 = require("app.utils.Md5")
require("app.utils.ImageUtils")
require("app.utils.NodeEx")