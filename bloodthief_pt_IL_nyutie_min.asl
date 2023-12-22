// servers as a minimal timer reader + attempt counter

state("bloodthief_v0.01")
{
    double timer: 0x43D9660, 0x248, 0x0, 0x70, 0x58, 0x98;
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
