pragma solidity ^0.5.0;

contract Ballot {
    // This is a struct containing the address
    struct voters{
        address adr;
    }
    // THis is a struct variable that will contain the voterName and if he voted or not.
    struct voter{
        bool voted;
        uint weight;
    }
    //Creating Propsal struct that will contain the voteCount and the name of the Dog.
    struct Proposal {                 
        uint voteCount;
        string DogName;
    }
    //This proposal two will later be mapped and revealed to anyone, so that people know which dog is related to which number.
    struct Proposal2{
        string DogNamee;
    }
    // Here are bunch of variables that will be used later on, mainly as counter.
    uint public totalVoter = 0; //Users can check the total number of voters.
    uint public totalVote = 0; //Users can check the total number of votes.
    uint public countdogs=0; // User can check how many dog are on the list
    address public ballotOfficialAddress; //User can access the address of the owner.
    uint public starttime;
    //RulesBook is to be read by users before voting.
    string public RulesBook= "Rule 1: Some Functions can only be accessed by the Owner (doVote, addcadidates, startVote, endVote) Rule 2: Some functions can only be accessed in certain state, for instance, you cannot vote if the voting has ended. Rule 3: Check how many dogs there are by using the countdogs button. Each dog is mapped from 0 to this number-1. You could check each dog's number to vote for using the Candidatesinfo. The number you include while voting should not be equal or less to the countdogs. Rule 4: You can only vote once. Rule 5: You can check who won by clicking on reqWinner, you can check the if the voting has started or no with the state button, you can check if a certain address has registered and check whether he voted or not and the weight associated to it.";
    
    // Here we are creating the hash tables.
    mapping(address => voter) public voterRegister;
    mapping(uint => voters) public addresses;
    mapping(uint => Proposal) private Candidates; // people cannot easily access how each candidate is doing
    mapping(uint => Proposal2) public Candidatesinfo;
    
    // For the states.
    enum State { Created, Voting, Ended }
    // We initialized a variable called state of the enum State.
	State public state;
	//Array of Proposal
    Proposal[] proposals;
    
    constructor() public {
	    //Store the address of the owner    
        ballotOfficialAddress = msg.sender;
        //Change the state to Created
        state = State.Created;
    }
    
    // This modifier will be used later on, for function can only be used by the owner.
	modifier onlyOfficial() {
		require(msg.sender ==ballotOfficialAddress, "Refer to Rule 1 in the RulesBook");
		_;
	}
    
    // This is used for function that can only be used at specific states.
	modifier inState(State _state) {
		require(state == _state, "Refer to rules 2 of the RulesBook");
		_;
	}
	//This function will be used later by the vote function in order to prevent people from double voting.
	modifier votecondition(uint toProposal){
	    require(!voterRegister[msg.sender].voted &&  toProposal < countdogs, "Refer to the Rule 3 of voting or Rule 4 of the RulesBook" );
	    _;
	}
	//This modifer is made to set a duration for the vote
	modifier endtime(){
	    require (starttime>= now +9 hours);
	    _;
	}//This modifer will be used to end the vote regardless of the owner
	modifier endtime2(){
	    require (starttime>= now +10 hours);
	    _;
	} 
	
	event voterAdded(address voter);
    event voteStarted();
    event voteEnded();
    event voteDone(address voter);
    //With this function, the owner can add as many candidates a he wants. This function also makes sure that no two candidates with the same name can happen
    function addcadidates(string memory DogName) public
    inState(State.Created)
    onlyOfficial {
        for (uint i=0; i<countdogs; i++){
            if ( keccak256(bytes(Candidates[i].DogName))==keccak256(bytes(DogName))) return;
        }
        Candidates[countdogs].DogName=DogName;
        Candidates[countdogs].voteCount=0;
        Candidatesinfo[countdogs].DogNamee=DogName;
        countdogs++;
    }
    
    //Here, we are adding as many voter as we want.
    function addVoter(address _voterAddress)
        public
        inState(State.Created)
        onlyOfficial //This can only work if the state is Created and it can only be executed by the owner. It takes the voter name and voter address
    {
        for (uint i=0; i<totalVoter; i++){
            if (addresses[i].adr==_voterAddress) return; //This for loop will check if the owner added the same address twice and will not take it
        }
        voter memory v; //initialize a variable
        voters memory v1;// initialize a variable
        v.voted = false; // He did not vote
        v1.adr= _voterAddress; //Storing the address so people can later on see the addresses of the voters
        if (_voterAddress==ballotOfficialAddress){
            v.weight=2;} //Owner has a weight of 2
        else{
            v.weight=1; //Normal voters have a weight of 1
        }
        voterRegister[_voterAddress] = v; // Adding the hash table.
        addresses[totalVoter]= v1;//Adding to the addresses hash table.
        totalVoter++; // Counting how many voters
        emit voterAdded(_voterAddress); 
    }//Note that here, we are storing these data into a public variable which makes it easy for everyone to see who is registered and who is not.
    
    //declare voting starts now. 
    function startVote()
        public
        inState(State.Created) // this function should have as state Created
        onlyOfficial // Here only the only the owner can created it 
    {
        state = State.Voting; // Change the stat to Voting.
        starttime=now;
        emit voteStarted();
    }
     //voters vote by indicating their choice
    function doVote(uint toProposal)
        public
        inState(State.Voting) //State should be voting
        votecondition(toProposal) //No double voiters
    {
        voterRegister[msg.sender].voted = true; // Change the voting to false
        Candidates[toProposal].voteCount += voterRegister[msg.sender].weight; //Adding the weight to the vote count
        totalVote++; // Counter gets +1
    }
       //end votes
    function endVote()
        public
        inState(State.Voting) //State should be votinh
        onlyOfficial //Only owner
        endtime // Can be executed after 9 hours of the start of the vote
    {
        state = State.Ended;
        emit voteEnded();
    }
     function endVote2() //Ends the vote completely after 10 hourse
    private
    endtime2
    {
        emit voteEnded();
    }
    //This function will send the name of the winner it can only be executed when the vote has ended
     function reqWinner() public inState(State.Ended) view returns (string memory _winningProposal) {
        uint256 winningVoteCount = 0;
        for (uint8 prop = 0; prop < countdogs; prop++) 
            if (Candidates[prop].voteCount > winningVoteCount) {
                winningVoteCount = Candidates[prop].voteCount;
                _winningProposal =  Candidates[prop].DogName;
            }
       assert(winningVoteCount>=1);
    }
    //This function will send the results for other voters
    function View_Scores(uint num)  public  inState(State.Ended) view  returns(uint score, string memory name){
        score= Candidates[num].voteCount;
        name= Candidates[num].DogName;
        return (score, name);
    }
   
}
