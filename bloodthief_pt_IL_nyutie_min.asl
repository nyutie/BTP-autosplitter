// servers as a minimal timer reader + attempt counter

state("bloodthief_v0.01", "pre-patch13") // ✔
{
    double timer: 0x43D9660, 0x248, 0x0, 0x70, 0x58, 0x98; 
}

state("bloodthief_v0.01", "patch13") // ✔
{
    double timer: 0x420DE40, 0x278, 0x0, 0x68, 0x28, 0x98;
}

state("bloodthief_v0.01", "patch14") // ✔
{
    double timer: 0x420DE40, 0x278, 0x0, 0x68, 0x28, 0xB0;
}

state("bloodthief_v0.01", "patch15") // ✔
{
    double timer: 0x420DE40, 0x608, 0x0, 0x68, 0x28, 0xB0;
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
            "SS-autosplitter | LiveSplit",
            MessageBoxButtons.YesNo,
            MessageBoxIcon.Question
        );
        if (timingMessage == DialogResult.Yes) timer.CurrentTimingMethod = TimingMethod.GameTime;
    }

    settings.Add("force_reset", true, "Force reset");
    settings.SetToolTip("force_reset", "Will force reset the livesplit timer if the IGT is reset. (Normally if you manually split to end the timer, it wouldn't reset. This forces it to do so.)");
}

init {
    var versionMap = new System.Collections.Generic.Dictionary<string, string>
    {
        { "F26811B1A3289C7D1CEE268E15ADCC0F", "patch13" }
    };

    string pckMD5Hash; // get hash of .pck file of game
    using (var md5 = System.Security.Cryptography.MD5.Create())
    using (var s = File.Open(modules.First().FileName.Replace("exe", "pck"), FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
    pckMD5Hash = md5.ComputeHash(s).Select(x => x.ToString("X2")).Aggregate((a, b) => a + b);

    version = versionMap.TryGetValue(pckMD5Hash, out version) ? version : "pre-patch13"; // if hash not found in dict, default to pre-patch13

    print("Version: '" + version + "' with hash '" + pckMD5Hash + "'");
}

update
{
    if (settings["force_reset"]
        && current.timer < old.timer)
    {
        vars.TimerModel.Reset(); // so you don't have to reset manually after beating level
    }
}

start
{
    if (old.timer > current.timer) // timer actually ticks on the main menu and is reset to 0 on game start
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

exit
{
    vars.TimerModel.Reset();
}
