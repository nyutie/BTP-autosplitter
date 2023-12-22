state("bloodthief_v0.01")
{
    // all of these pointers work on downpatches, probably will work on newer patches too. if not I'll add proper version control.
    double timer: 0x43D9660, 0x248, 0x0, 0x70, 0x58, 0x98; 
    int checkpointID: 0x43D9660, 0x248, 0x0, 0x70, 0x58, 0xE0;
    bool isOnResultScreen: 0x43D9660, 0x280, 0x3D0, 0x10, 0x414;
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

    settings.Add("split_on_group", true, "Split on");
    settings.SetToolTip("split_on_group", "Which of these events should trigger a split");
    settings.Add("split_on_checkpoint_increase", true, "Checkpoint get", "split_on_group");
    settings.SetToolTip("split_on_checkpoint_increase", "Will split whenever you get a higher checkpoint id.");
}

init {}

update
{
    if (current.timer < old.timer)  {
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
