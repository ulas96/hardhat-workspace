// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}


contract Bucket {
    event Winner(address);

    address internal excelciumAddress = 0x9e6969254D73Eda498375B079D8bE540FB42fea7;

    IERC20 internal excelcium = IERC20(excelciumAddress);

    function drop(uint amount) external {
        require(amount > 0);
        require(excelcium.transferFrom(msg.sender, address(this), amount));
        emit Winner(msg.sender);
    }
}
