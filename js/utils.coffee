pudu = {}

pudu.defaultSetting =
  version: '1.0'

#========== STORAGE ==========#

pudu.setLocalStorage = (data, func = ->)->
  chrome.storage.local.set data, func

pudu.getLocalStorage = (func)->
  chrome.storage.local.get func

pudu.clearLocalStorage = (func = ->)->
  chrome.storage.local.clear(func)

pudu.removeLocalStorage = (key, func = ->)->
  chrome.storage.local.remove(key, func)

pudu.getExtensionUrl = (uri)->
  chrome.extension.getURL uri

pudu.isOptionEnable = (optionName, onEnable, onDisable = ->)->
  pudu.getLocalStorage (items)->
    if items[optionName] == undefined or items[optionName] == true
      onEnable()
    else
      onDisable()

pudu.getOptionBoolean = (optionName, callback)->
  pudu.isOptionEnable optionName,
    (-> callback(true)), (-> callback(false))

# Simply compares two string version values.
#
# Example:
# versionCompare('1.1', '1.2') => -1
# versionCompare('1.1', '1.1') =>  0
# versionCompare('1.2', '1.1') =>  1
# versionCompare('2.23.3', '2.22.3') => 1
#
# Returns:
# -1 = left is LOWER than right
#  0 = they are equal
#  1 = left is GREATER = right is LOWER
#  And FALSE if one of input versions are not valid
#
# @function
# @param {String} left  Version #1
# @param {String} right Version #2
# @return {Integer|Boolean}
# @author Alexey Bass (albass)
# @since 2011-07-14
pudu.versionCompare = (left, right)->
  if typeof left + typeof right != 'stringstring'
    return false;

  a = left.split('.')
  b = right.split('.')
  i = 0
  len = Math.max(a.length, b.length);

  while i < len
    if ((a[i] && !b[i] && parseInt(a[i]) > 0) || (parseInt(a[i]) > parseInt(b[i])))
      return 1;
    else if ((b[i] && !a[i] && parseInt(b[i]) > 0) || (parseInt(a[i]) < parseInt(b[i])))
      return -1;
    i++

  return 0;

#========== WATCHER ==========#

pudu.watcher = {}
pudu.watcherLoop = ()->
  for name, func of pudu.watcher
    func() # exec each watcher
  setTimeout pudu.watcherLoop, 1000 # repeat

pudu.watcherElementIterator = ($elements, iterator)->
  $elements.each ->
    if not $(@).data('__done__')
      notDone = iterator($(@), @)
      $(@).data('__done__', notDone != true) # change result to boolean

#========== INIT ==========#

# init default setting if is first time, then refresh
pudu.getLocalStorage (items)->
  # if not have setting data yet, just added default
  if items.version is undefined
    pudu.setLocalStorage pudu.defaultSetting, ->
      window.location.reload()
    # if current version is newer, just added only new default setting
  else if pudu.versionCompare(items.version, pudu.defaultSetting.version) == -1
    # assign new version
    items.version = pudu.defaultSetting.version
    # add only not exist
    pudu.setLocalStorage $.extend(pudu.defaultSetting, items), ->
      window.location.reload()

window.pudu = pudu