return {
    Name = 'Kill';
    Aliases = {'end', "terminate"};
    Description = 'Kills the provided user(s)';
    Group = 2;
    Args = {
        {
            Type = 'players';
            Name = 'Player(s)';
            Description = 'Player(s) to kill'
        }
    }
}