state("bloodthief_v0.01", "pre-patch12") // ✔
{ // all of these pointers work on downpatches, probably will work on newer patches too. if not I'll add proper version control. - I had to add proper verison control
    double timer: 0x43D9660, 0x248, 0x0, 0x70, 0x58, 0x98; 
    int checkpointID: 0x43D9660, 0x248, 0x0, 0x70, 0x58, 0xE0;
    bool isOnResultScreen: 0x43D9660, 0x280, 0x3D0, 0x10, 0x414;
}

state("bloodthief_v0.01", "patch12") // ✔
{
    double timer: 0x43D9660, 0x248, 0x0, 0x70, 0x58, 0x98;
    int checkpointID: 0x43D9660, 0x248, 0x0, 0x70, 0x58, 0xE0;
    bool isOnResultScreen: 0x43D9660, 0x280, 0x180, 0x10, 0x414;
}

state("bloodthief_v0.01", "patch13") // ✔
{
    double timer: 0x420DE40, 0x278, 0x0, 0x68, 0x28, 0x98;
    int checkpointID: 0x420DE40, 0x278, 0x0, 0x68, 0x28, 0xE0;
    bool isOnResultScreen: 0x420DE40, 0x2B0, 0x178, 0x10, 0x40C;
}

state("bloodthief_v0.01", "patch14") // ✔
{
    double timer: 0x420DE40, 0x278, 0x0, 0x68, 0x28, 0xB0;
    int checkpointID: 0x420DE40, 0x278, 0x0, 0x68, 0x28, 0xF8;
    bool isOnResultScreen: 0x420DE40, 0x2B0, 0x178, 0x10, 0x40C;
}

state("bloodthief_v0.01", "patch15") // ✔
{
    double timer: 0x420DE40, 0x278, 0x0, 0x68, 0x28, 0xB0;
    int checkpointID: 0x420DE40, 0x278, 0x0, 0x68, 0x28, 0xF8;
    bool isOnResultScreen: 0x420DE40, 0x2B0, 0x178, 0x10, 0x40C;
}

state("bloodthief_v0.01", "patch16") // ✔
{
    double timer: 0x420DE40, 0x278, 0x0, 0x68, 0x28, 0xC8;
    int checkpointID: 0x420DE40, 0x278, 0x0, 0x68, 0x28, 0x110;
    bool isOnResultScreen: 0x420DE40, 0x2B0, 0x178, 0x18, 0x40C;
}

state("bloodthief_v0.01", "patch 0.1.17") // ✔
{
    double timer: 0x420DE40, 0x278, 0x0, 0x68, 0x28, 0xC8;
    int checkpointID: 0x420DE40, 0x278, 0x0, 0x68, 0x28, 0x128;
    bool isOnResultScreen: 0x420DE40, 0x2B0, 0x178, 0x18, 0x40C;
}

state("bloodthief_v0.01", "patch 0.1.18") // ✔
{
    double timer: 0x420DE40, 0x278, 0x0, 0x68, 0x28, 0xC8;
    int checkpointID: 0x420DE40, 0x278, 0x0, 0x68, 0x28, 0x128;
    bool isOnResultScreen: 0x420DE40, 0x2B0, 0x178, 0x18, 0x40C;
}

startup
{
    vars.TimerModel = new TimerModel { CurrentState = timer };

    if(timer.CurrentTimingMethod == TimingMethod.RealTime) // copied this from somewhere lmao
    {
        var timingMessage = MessageBox.Show
        (
            "This game uses Game Time (time without loads) as the main timing method.\n"+
            "LiveSplit is currently set to show Real Time (time INCLUDING loads).\n"+
            "Would you like the timing method to be set to Game Time for you?",
            "BTP-autosplitter | LiveSplit",
            MessageBoxButtons.YesNo,
            MessageBoxIcon.Question
        );
        if (timingMessage == DialogResult.Yes) timer.CurrentTimingMethod = TimingMethod.GameTime;
    }

    settings.Add("split_on_group", true, "Split on");
    settings.SetToolTip("split_on_group", "Which of these events should trigger a split");
    settings.Add("split_on_checkpoint_increase", true, "Checkpoint get", "split_on_group");
    settings.SetToolTip("split_on_checkpoint_increase", "Will split whenever you get a higher checkpoint id.");
}

init {
    var versionMap = new System.Collections.Generic.Dictionary<string, string>
    {
        { "2399A6209172AAD3F9AE64939D1FCF68", "patch12" },
        { "F26811B1A3289C7D1CEE268E15ADCC0F", "patch13" },
        { "DBED6E2B572F57D4C981EE1B73EEE25B", "patch14" },
        { "BE7590E4E8F9A51CF855A92E97AA908A", "patch15" },
        { "10FFB6E960F5C6B1541309EE7A7F3B56", "patch16" },
        { "54FD098BD9CEB76FCA0DD27A3F6739F2", "patch 0.1.17" },
        { "E9145AC2F5C3A6502833493B99D7EE18", "patch 0.1.18" }
    };

    string pckMD5Hash; // get hash of .pck file of game
    using (var md5 = System.Security.Cryptography.MD5.Create())
    using (var s = File.Open(modules.First().FileName.Replace("exe", "pck"), FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
    pckMD5Hash = md5.ComputeHash(s).Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);

    version = versionMap.TryGetValue(pckMD5Hash, out version) ? version : "pre-patch12"; // if hash not found in dict, default to pre-patch12

    print("Version: '" + version + "' with hash '" + pckMD5Hash + "'");
}

update
{
    if (current.timer < old.timer) 
    {
        vars.TimerModel.Reset(); // so you don't have to reset manually after beating level
    }
}

start
{
    if (current.timer > 0) // timer actually ticks on the main menu and is reset to 0 on game start. also checks whether timer is above 0 to avoid starting a run on game close
    {
        return true;
    }
}

split
{
    if (current.isOnResultScreen && !old.isOnResultScreen) {
        return true;
    }
    if (settings["split_on_checkpoint_increase"]
        && current.checkpointID > old.checkpointID)
    {
        return true;
    }
}

reset
{
    if (current.timer < old.timer)
    {
        return true;
    }
}

isLoading
{
    if (current.timer == old.timer)
    {
        return true;
    }
}

gameTime
{
    return TimeSpan.FromSeconds(current.timer);
}

onReset {}

exit
{
    // I'd have to figure out a way where the update block doesn't reset the timer on exit. exit is called around a full second after the game is closed with causes issues.
    // if (timer.CurrentPhase != TimerPhase.Ended)
    // {
    //     vars.TimerModel.Reset();
    // }
}
