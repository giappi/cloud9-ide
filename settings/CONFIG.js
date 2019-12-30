
const PATH_USER             = process.env.HOME;
const PATH_C9               = process.cwd();
const PATH_HOME             = PATH_USER; //process.cwd() + "/home";
const PATH_BIN              = PATH_USER + "/.c10";
const PATH_NODE             = process.execPath;

module.exports = 
{
    c9Path:         PATH_C9,
    home:           PATH_HOME,
    c9binPath:      PATH_BIN,
    platform:       process.platform,
    arch:           process.arch,
    tmux:           PATH_BIN + "/bin/tmux",
    nakBin:         PATH_C9 + "/node_modules/nak/bin/nak",
    bashBin:        "bash",
    nodeBin:        PATH_NODE,
    installPath:    PATH_BIN,
    settingDir:     PATH_HOME
};

console.log("HTTP_IP    :", process.env.IP);
console.log("HTTP_PORT  :", process.env.PORT);
