return {
    Name = 'Ragdoll';
    Aliases = {'ragd', "flop"};
    Description = 'Ragdolls the provided user';
    Group = 3;
    Args = {
        {
            Type = 'player';
            Name = 'Player';
            Description = 'Player to ragdoll'
        }
    }
}