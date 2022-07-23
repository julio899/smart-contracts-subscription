// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
/*
 * @title TopacioSubscription
 * @dev Subscriptions Topacio - Julio Vinachi
 * @url https://github.com/topaciotrade/smart-contracts-subscription/blob/main/TopacioSubscription.sol
 */
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TopacioSubscription {

    uint lastSubscription;
    uint priceOfSubscription = 100000000000000000;  
    bool newSubscriptionEnable = false;
    bool isActiveCustomToken = false;
    uint maxNewSubscriptors = 50;  
    uint controlTotalSubscriptors = 0;
    uint controlNewSubscriptor = 0;
    IERC20 public token;

    address payable public stakingInfrastructure = payable(0x84c64c039e3697F2C997887735e9d488DC17AA40);
    
    struct Subscription {
        uint controldate; // initial start date
        bool active;  // if true, active
        address delegate; // person delegated to
        uint amountSubscription;
        uint nro;
        uint tikets;
        uint endsubscription; // final date subscription
    }
    address[] public addressSubscriptors;
    mapping(address => Subscription) public subscriptions;

    address private owner;

    event Received(address, uint);
    event NewRegisterSubscriptor(address Subscriptior, uint amount,uint start,uint end);
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    /**
     * @dev Set contract deployer as owner
     */
    constructor() payable {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
    }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }

    modifier onlySubscriber(){
       Subscription storage consult = subscriptions[msg.sender];
       require(consult.delegate == msg.sender,"you are not of this subscriptior");
        _;
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
    
    /**
     * Change owner contract
     */
     function changeOwner(address newOwner) onlyOwner public 
    {
        owner = newOwner;
    }

    /**
     * Active Pay Only for token Custom
     */
    function activePayByToken(address _token,uint _initialCost) onlyOwner public 
    {
        isActiveCustomToken = true;
        priceOfSubscription = _initialCost;
        token = IERC20(_token);
    }

    function InactivePayByToken() onlyOwner public returns (bool)
    {
        isActiveCustomToken = false;
        return true;
    }

    function getIsActivePayByToken() external view returns (bool) 
    {
        return isActiveCustomToken;
    }

    function getBalanceInToken() public view returns (uint256)
    {        
        require(isActiveCustomToken == true, "Token is not active");
        return token.balanceOf(address(msg.sender));
    }


    function getDateLastSubscription() external view returns (uint){
        return lastSubscription;
    }

    function comprar() public payable {
        

        require ( maxNewSubscriptors > 0 , "No have quota for new Subscription");  
        require ( newSubscriptionEnable == true,"No enable for new subscription" );
        require(msg.value == priceOfSubscription, "Incorect amount");
        
        if(isActiveCustomToken==true){

            require ( token.balanceOf(address(msg.sender)) >= priceOfSubscription,"you need balance in topacio token" );
            uint256 allowance = token.allowance(msg.sender, address(this));
            require(allowance >= priceOfSubscription, "check the token allowance");
                  
            token.transferFrom(msg.sender,address(this), priceOfSubscription);

        }else{
            payable(this).transfer(priceOfSubscription);
        }

        
        maxNewSubscriptors = maxNewSubscriptors-1;
        lastSubscription = block.timestamp;

        controlTotalSubscriptors+=1;

       Subscription storage consult = subscriptions[msg.sender];
        if(!consult.active){
            controlNewSubscriptor+=1;
            subscriptions[msg.sender].nro = controlNewSubscriptor;
            subscriptions[msg.sender].controldate = block.timestamp;
            subscriptions[msg.sender].endsubscription = block.timestamp + 31 days;
            addressSubscriptors.push(msg.sender);
        }else{
            // si ya esta activo y tiene subscription
            subscriptions[msg.sender].endsubscription += 31 days;
        }
        
        
        subscriptions[msg.sender].amountSubscription += msg.value;
        subscriptions[msg.sender].active = true; 
        subscriptions[msg.sender].delegate = msg.sender;
        subscriptions[msg.sender].tikets+=1;
        
        if ( maxNewSubscriptors == 0 ) {
            newSubscriptionEnable = false;
        }
        
        emit NewRegisterSubscriptor(msg.sender, msg.value,block.timestamp, (block.timestamp + 31 days));
    
    }
 
    function tokensBalance()external view returns(uint256){
        return token.balanceOf(address(this));
    }

    function getTickets() onlySubscriber external view returns (uint){
       Subscription storage consult = subscriptions[msg.sender];
       return consult.tikets;
    }

    function spendTickets(uint _countTicket) onlySubscriber external returns (bool){
       Subscription storage consult = subscriptions[msg.sender];
       require (consult.tikets>=_countTicket,"you not have enough Tickets");
       require (consult.tikets!=0 && _countTicket!=0,"Tickets cannot be zero");
       subscriptions[msg.sender].tikets = consult.tikets-_countTicket;
       return true;
    }

    function assignTickets(uint _countTicket, address _addressSubscriber) onlyOwner external {
       Subscription storage consult = subscriptions[_addressSubscriber];
       require (consult.delegate == _addressSubscriber,"Subscriber no exist");
       require (_countTicket>0,"Tickets cannot be zero");
       subscriptions[_addressSubscriber].tikets += _countTicket;
    }

    function burnTickets(uint _countTicket, address _addressSubscriber) onlyOwner external {
       Subscription storage consult = subscriptions[_addressSubscriber];
       require (consult.tikets>=_countTicket,"you not have enough Tickets");
       require (consult.tikets!=0 && _countTicket!=0,"Tickets cannot be zero");
       consult.tikets = consult.tikets-_countTicket;
    }

    function getAllSubscriptions() external view returns (address[] memory) {
        return addressSubscriptors;
    }

    function getDateEndSubscription()  external view returns (uint){
       Subscription storage consult = subscriptions[msg.sender];
       require(consult.active,"no has subscription");
       return consult.endsubscription;
    }

    function getDateInitialSubscription()  external view returns (uint){
       Subscription storage consult = subscriptions[msg.sender];
       require(consult.active,"no has subscription");
       return consult.controldate;
    }

    function isSubscriber()  external view returns (bool){
       Subscription storage consult = subscriptions[msg.sender];
       return (consult.active);
    }

    function getDaysSubscription()  external view returns (uint){
       Subscription storage consult = subscriptions[msg.sender];
       require(consult.active,"no has subscription");
       return (consult.endsubscription - block.timestamp) / 1 days;
    }

    function getHistoryAmountSubscriptions()  external view returns (uint){
       Subscription storage consult = subscriptions[msg.sender];
       require(consult.active,"no has subscription");
       return (consult.amountSubscription);
    }

    function getSubscriptorNro()  external view returns (uint){
       Subscription storage consult = subscriptions[msg.sender];
       require(consult.active,"no has subscription");
       return (consult.nro);
    }

    function searchSubscriptorNro(address _addressSubscriber)  external view returns (uint){
       Subscription storage consult = subscriptions[_addressSubscriber];
       return (consult.nro);
    }

    function getTotalSubscriptions()  external view returns (uint){
       return controlTotalSubscriptors;
    }

    function searchSubscriber(address _addressSubscriber)  external view returns (bool){
       Subscription storage consult = subscriptions[_addressSubscriber];
       return (consult.nro > 0);
    }

    function getStatusSubscriptionsRegister()  external view returns (bool){
       return newSubscriptionEnable;
    }

    function getSubscripcionesDisponibles()  external view returns (uint){
       return maxNewSubscriptors;
    }

    function getBalanceSuscriptions() onlyOwner external view returns (uint256){
       return address(this).balance;
    }

    function getStakingBalance() onlyOwner external view returns (uint256){
       return address(stakingInfrastructure).balance;
    }

    function getCosto() external view returns (uint256){
       return priceOfSubscription;
    }

    function updateCostSubscription( uint _new_cost ) onlyOwner public{
        priceOfSubscription = _new_cost;
    }

    function startingSubscriptions( uint _max_subscriptiors ) onlyOwner public{
        maxNewSubscriptors = _max_subscriptiors;  
        newSubscriptionEnable = true;
    }

    function stopRegistersSubscriptions( ) onlyOwner public{
        maxNewSubscriptors = 0;  
        newSubscriptionEnable = false;
    }

    function changeStaking( address _addressStaking ) onlyOwner public{
        stakingInfrastructure = payable(_addressStaking);
    }

    function toStakingInfrastructure() onlyOwner public payable{
       if(isActiveCustomToken==true) {
        uint cantidad = token.balanceOf(address(this));
        require( cantidad > 0,"contract not have enough balance");
        token.transfer(address(stakingInfrastructure),cantidad);
       }else{
        require(address(this).balance > 0,"contract not have enough balance");
        stakingInfrastructure.transfer(address(this).balance);
       }

    }

    // important to receive ETH
    // receive() payable external {}
}
