pragma solidity ^0.5.17;


contract LebaneseLoto{
//Price of a ticket 
uint public constant TicketPrice = 1 ether;
//There are only 42 numbers in lebanes loto and the user should not exceed them
uint public constant maxnum = 42; 
// Each 3 days, a round ends
uint public constant Roundtime = 3 days;

//round number
uint public round;

// Struct round containing the endtime of the round. It will contain the winningNumbers.
// It also contains every ticket that each address made.
address Owner;
struct Round {
uint endTime;
uint drawBlock;
uint[] winningNumbers;
mapping(address => uint[6][]) tickets;
}


// mapping number with each Round Struct
mapping(uint => Round) public rounds;

//When starting this contract, we assign the round to 1 as it is the first round. This is important because we will match each ticke with the following round
//Meaning that people cannot. Also we are setting the round lentgh.
    constructor() public{
        Owner=msg.sender;
        round=1;
        rounds[round].endTime=now+ Roundtime; 
    }
//Function buy. This is a payable function that will allow a person to buy tickets. 
//The first for loop will make sure that the number are inserted correctly
//The second for loop pushes the tickets one by one to the tickets hash table

    function buytickets ( uint[6][] memory numbers)  public payable {
    require(numbers.length * TicketPrice == msg.value, "The amount payed is not sufficient");
        for (uint a=0; a< numbers.length; a++){
            for (uint b=0; b<6; b++) //
                for (uint c=b+1; c<6; c++){
                    require(numbers[a][b]!=numbers[a][c], "You cannot draw the same number twice");}
        }
        for (uint i=0; i < numbers.length; i++) {
            for (uint j=0; j < 6; j++){
                require(numbers[i][j] > 0, "The numbers are between 1 and 42");
                require(numbers[i][j] <= maxnum,"The numbers are between 1 and 42");}
        if (now > rounds[round].endTime) {
            rounds[round].drawBlock = block.number + 5;
            round += 1;
            rounds[round].endTime = now + Roundtime;
        }
        for (i=0; i < numbers.length; i++){
            rounds[round].tickets[msg.sender].push(numbers[i]);}
    }
    }
    function Draw (uint _round) public {
        uint drawBlock = rounds[_round].drawBlock;
        require(now > rounds[_round].endTime, "Round did not end yet"); //Checking if the round's time has ended
        require(drawBlock!=0,"Round did not end yet");
        require(rounds[_round].winningNumbers.length == 0, "Winning Numbers are already drawn");//Checking if the draw has not been made
        require(Owner==msg.sender, "Access limited for the creator");
        while(rounds[_round].winningNumbers.length<7) {
            bytes32 rand =  keccak256(abi.encodePacked(rounds[_round].winningNumbers.length, drawBlock)); 
            uint numberDraw = uint(rand) % maxnum + 1;
            for(uint i=0;i<rounds[_round].winningNumbers.length; i++){
                require(rounds[_round].winningNumbers[i]!=numberDraw, "Generated numbers are equal");
            }
            rounds[_round].winningNumbers.push(numberDraw);
    }
    }


    function Get_rewards (uint _round) public payable {
        require(rounds[_round].tickets[msg.sender].length > 0,"Sorry, you did not buy any tickets"); //The user have bought at least 1 ticket
        require(rounds[_round].winningNumbers[0] != 0, "Sorry, the winning numbers still did not appear"); //The winningNumbers are droawn
        uint[6][] storage myNumbers = rounds[_round].tickets[msg.sender];
        uint[] storage winningNumbers = rounds[_round].winningNumbers;
        uint payout = 0;
        for (uint i=0; i < myNumbers.length; i++) {
            uint numberMatches = 0;
            for (uint j=0; j < 6; j++) {
                for (uint k=0; k < 6; k++) {
                    if (myNumbers[i][j] == winningNumbers[k])
                     numberMatches += 1;}
            }
        if (numberMatches == 5){
            for (uint l=0; i < myNumbers.length; i++)
                 for (uint p=0; p < 6; p++) {
                    if (myNumbers[l][p] == winningNumbers[6])
                         numberMatches += 2;
        }
        }
        if (numberMatches == 6) {
            payout += 100 ether;
        }
        else if (numberMatches == 7){
            payout += 5 ether;}
        else if (numberMatches == 5){
            payout += 1 ether;}
        else if (numberMatches == 4){
            payout +=  1e17 ;}
        else if(numberMatches ==3){
            payout += 4e15 ;}
    }
    msg.sender.transfer(payout); // include message
    delete rounds[_round].tickets[msg.sender];
    }
    function ticketsFor(uint _round, address user) public view
        returns (uint[6][] memory tickets) {
        return rounds[_round].tickets[user];
    }
    function winningNumbersFor(uint _round) public view
        returns (uint[] memory winningNumbers) {
        return rounds[_round].winningNumbers;
    }

}




