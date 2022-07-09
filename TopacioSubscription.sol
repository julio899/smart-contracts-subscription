// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.7;

/*
 * @title TopacioSubscription
 * @dev Subscriptions Topacio - Julio Vinachi
 * @url https://github.com/topaciotrade/smart-contracts-subscription/blob/main/TopacioSubscription.sol
 */
contract TopacioSubscription {

    uint lastSubscription;
    uint costoSubscription = 100000000000000000;  
    bool newSubscriptionEnable = false;
    uint maxNewSubscriptors = 50;  
    uint controlTotalSubscriptors = 0;
    uint controlNewSubscriptor = 0;  

    address payable public stakingInfrastructure = payable(0x84c64c039e3697F2C997887735e9d488DC17AA40);
    


    struct Subscription {
        uint controldate; // initial start date
        bool active;  // if true, active
        address delegate; // person delegated to
        uint amountSubscription;
        uint nro;
        uint endsubscription; // final date subscription
    }

    mapping(address => Subscription) public subscriptions;

    address private owner;

    event Received(address, uint);
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


    function getDateLastSubscription() external view returns (uint){
        return lastSubscription;
    }

    function comprar() public payable {

        require(msg.value == costoSubscription, "Incorect ammount");
        require ( maxNewSubscriptors > 0 , "No have quota for new Subscription");  
        require ( newSubscriptionEnable == true,"no enable for new subscription" );

        payable(this).transfer(msg.value);
        
        maxNewSubscriptors = maxNewSubscriptors-1;
        lastSubscription = block.timestamp;

        controlTotalSubscriptors+=1;

       Subscription storage consult = subscriptions[msg.sender];
        if(!consult.active){
            controlNewSubscriptor+=1;
            subscriptions[msg.sender].nro = controlNewSubscriptor;
            subscriptions[msg.sender].controldate = block.timestamp;
            subscriptions[msg.sender].endsubscription = block.timestamp + 31 days;
        }else{
            // si ya esta activo y tiene subscription
            subscriptions[msg.sender].endsubscription += 31 days;
        }
        
        
        subscriptions[msg.sender].amountSubscription += msg.value;
        subscriptions[msg.sender].active = true; 
        subscriptions[msg.sender].delegate = msg.sender;
        
        if ( maxNewSubscriptors == 0 ) {
            newSubscriptionEnable = false;
        }
    }

    function getDateEndSubscription()  external view returns (uint){
       Subscription storage consult = subscriptions[msg.sender];
       return consult.endsubscription;
    }

    function getDateInitialSubscription()  external view returns (uint){
       Subscription storage consult = subscriptions[msg.sender];
       return consult.controldate;
    }

    function isSubscriber()  external view returns (bool){
       Subscription storage consult = subscriptions[msg.sender];
       return (consult.active);
    }

    function getHistoryAmountSubscriptions()  external view returns (uint){
       Subscription storage consult = subscriptions[msg.sender];
       return (consult.amountSubscription);
    }

    function getSubscriptorNro()  external view returns (uint){
       Subscription storage consult = subscriptions[msg.sender];
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

    function getSubscriptoresDisponibles()  external view returns (uint){
       return maxNewSubscriptors;
    }

    function getBalanceSuscriptions()  external view returns (uint256){
       return address(this).balance;
    }

    function getStakingBalance()  external view returns (uint256){
       return address(stakingInfrastructure).balance;
    }

    function updateCostSubscription( uint _new_cost ) onlyOwner public{
        costoSubscription = _new_cost;
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
       stakingInfrastructure.transfer(address(this).balance);
    }

    // important to receive ETH
    // receive() payable external {}
}
