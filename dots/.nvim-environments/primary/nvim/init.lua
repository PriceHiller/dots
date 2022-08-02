local loaded, impatient = pcall(require, 'impatient')
if loaded then
    impatient.enable_profile()
end
require('main')
