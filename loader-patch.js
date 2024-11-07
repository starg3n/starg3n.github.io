(() => {
  var initStr = Loader.prototype.init.toString();
  initStr = initStr.slice(initStr.indexOf("{") + 1, initStr.lastIndexOf("}"));
  initStr = initStr.replace('"api/config"', '"api/config.json"');
  Loader.prototype.init = Function("callback", initStr);

  var runStr = Loader.prototype.run.toString();
  runStr = runStr.slice(runStr.indexOf("{") + 1, runStr.lastIndexOf("}"));
  runStr = runStr.replace('"api/categories"', '"api/categories.json"');
  runStr = runStr.replace('ajax("api/songs"', 'ajax("api/songs.json"');
  runStr = runStr.replace(
    ' + "fonts/"',
    ' + (gameConfig.assets_no_dir ? "" : "fonts/")'
  );
  runStr = runStr.replaceAll(
    ' + "img/"',
    ' + (gameConfig.assets_no_dir ? "" : "img/")'
  );
  runStr = runStr.replace(
    'gameConfig.assets_baseurl + "img/vectors.json"',
    '(gameConfig.assets_no_dir ? "vectors.json" : gameConfig.assets_baseurl + "img/vectors.json")'
  );
  runStr = runStr.replace(
    'directory + "main." + songExt',
    '(gameConfig.assets_no_dir ? gameConfig.assets_baseurl + song.id + "." + songExt : directory + "main." + songExt)'
  );
  Loader.prototype.run = Function(runStr);

  var soundUrlStr = Loader.prototype.soundUrl.toString();
  soundUrlStr = soundUrlStr.slice(
    soundUrlStr.indexOf("{") + 1,
    soundUrlStr.lastIndexOf("}")
  );
  soundUrlStr = soundUrlStr.replace(
    ' + "audio/"',
    ' + (gameConfig.assets_no_dir ? "" : "audio/")'
  );
  Loader.prototype.soundUrl = Function("name", soundUrlStr);
})();
