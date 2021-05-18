pragma solidity ^0.4.22;

contract Roulette{
    address owner;
    uint8 bettype;
    // 0 for numbers  
    // 1 for colors
    // 2 for odds or none odds
    // 3 for dozens choice
    // 4 for column choice
    // 5 for high or low bet
    
    // maximum and minimum numbers and counter
    uint8 public constant MaxNumber=36;
    uint8 public constant MinNumber=0;
    uint counter;

    
    // These hash function will be used in order for the player to determine the id to be used to spin the wheel
    mapping(address => uint[]) public Mapper;
    mapping(address => uint) public BetPlayed;
    
    uint gen_num;
    
    // New variable that contain information about the better
    struct better{
        address better_address;
        uint8 bettertype;
        uint8 betterchoice;
        uint amount;
    }
    better[] public betters;
    

     
    
    //Creating a hassh function. These will be used in the constructor to be able to match every number to each group. for instance 1 should be known as red number.
    mapping(uint => uint) public colors_match;
    mapping(uint => uint) public oddeven_match;
    mapping(uint => uint) public firstsecthird_match;
    mapping(uint => uint) public col_match;
    mapping(uint => uint) public lowhigh_match;
    
    mapping(uint => uint) public winning_num;
    
    //constructor doing the matching
    constructor() public{
    uint8[18] memory rednum = [
     1, 3, 5, 7, 9, 12,
     14, 16, 18, 19, 21, 23,
     25, 27, 30, 32, 34, 36
     ];
     uint8[18] memory evennumber = [
     2, 4, 6, 8, 10, 12,
     14, 16, 18, 20, 22, 24,
     26, 28, 30, 32, 35, 36
     ];
     uint8[12] memory first12 = [
     1,2,3,4,5,6,7,8,9,10,11,12];
     
     uint8[12] memory Second12 = [
     13,14,15,16,17,18,19,20,21,22,23,24];
     
     uint8[12] memory third12 = [
     25,26,27,28,29,30,31,32,33,34,35,36];
     
    uint8[12] memory firstcol = [
     1,4,7,10,13,16,19,22,25,28,31,34];
    
    uint8[12] memory secondcol = [
     2,5,8,11,14,17,20,23,26,29,32,35];
     
    uint8[12] memory thirdcol = [
     3,6,9,12,15,18,21,24,27,30,33,36];
    
    uint8[18] memory high = [
     19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36];
        owner = msg.sender;
        for (uint i=0; i < 18; i++) {
            colors_match[rednum[i]] = 1;
            oddeven_match[evennumber[i]]=1;}
        for(uint j=0; j<12;j++){
            firstsecthird_match[first12[j]]=1;
            firstsecthird_match[Second12[j]]=2;
            firstsecthird_match[third12[j]]=3;
            col_match[firstcol[j]]=1;
            col_match[secondcol[j]]=2;
            col_match[thirdcol[j]]=3;
        for(uint k=0; k<18;k++){//
            lowhigh_match[high[k]]=1;}
    }}

    //Function that will allow us to fund the smart contract in case all the ether are drained
    
    function addEther() payable public {
        require(msg.sender==owner);
    }
    
    
    //Function that allows us the player to bet
    
    function putyourbet(uint8 bet_type, uint8 Choice) public payable{
        require(msg.value>0);
        require(bet_type>=0 &&  bet_type<=5, "Choice out of boundary");
        if (bet_type==0){
            require(Choice<=MaxNumber && Choice >=MinNumber, "Number out of boundary");}
        else if (bet_type==1){
            require (Choice== 0 || Choice ==1, "You can only choose 1 or 0");}
        else if (bet_type==2){
            require(Choice== 0 || Choice ==1, "You can only choose 1 or 0");
        }
        else if (bet_type==3){
            require(Choice== 1 || Choice ==2 || Choice==3, "You can only choose 1, 2, or 3");
        }
        else if (bet_type==4){
            require(Choice== 1 || Choice ==2|| Choice==3, "You can only choose 1, 2, or 3");
        }
        else if (bet_type==5){
            require(Choice==0 || Choice==1, "You can only choose 1, 2, or 3");
        }

        
         
         counter++;
         
         betters.push(better({
         bettertype: bet_type,
         better_address: msg.sender,
         betterchoice: Choice,
         amount: msg.value
         }));
        Mapper[msg.sender].push(counter);
        BetPlayed[msg.sender]+=1 ;
        }
    
    //Spin the wheel
    function spin(uint _ID) public payable{
        //Calculate random number
        better storage better1 = betters[_ID];
        require(msg.sender == better1.better_address);
        better memory lb = betters[betters.length-1];
        better memory b = betters[_ID];
        gen_num = uint(keccak256(abi.encodePacked(now,lb.bettertype, lb.better_address, lb.betterchoice))) % (MaxNumber)+1;
        if (b.bettertype==0){
            if(gen_num== b.betterchoice){
                msg.sender.transfer(b.amount * 35);
                }
            }
        else if (b.bettertype==1){
            if(colors_match[gen_num]==b.betterchoice){
                msg.sender.transfer(b.amount * 2);
                    }
                }
        else if (b.bettertype==2){
            if(oddeven_match[gen_num]==b.betterchoice){
                msg.sender.transfer(b.amount * 2);
                    }
                }
         else if (b.bettertype==3){
            if(firstsecthird_match[gen_num]==b.betterchoice){
                msg.sender.transfer(b.amount * 3);
                    }
                }
        else if (b.bettertype==4){
            if(col_match[gen_num]==b.betterchoice){
                msg.sender.transfer(b.amount * 3);
                    }
                }
        else if (b.bettertype==5){
            if(lowhigh_match[gen_num]==b.betterchoice){
                msg.sender.transfer(b.amount * 6);
                    }
                }
         winning_num[_ID]=gen_num;
         delete betters[_ID];
            }
      
    
    function Kill() public {
    require(msg.sender == owner);
    selfdestruct (owner);
  }
               
} 
    