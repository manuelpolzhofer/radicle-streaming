// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.19;

import {Caller} from "src/Caller.sol";
import {GitDriver} from "src/GitDriver.sol";
import {
    DripsConfigImpl,
    DripsHub,
    DripsHistory,
    DripsReceiver,
    SplitsReceiver,
    UserMetadata
} from "src/DripsHub.sol";
import {ManagedProxy} from "src/Managed.sol";
import {Test} from "forge-std/Test.sol";
import {
    IERC20,
    ERC20PresetFixedSupply
} from "openzeppelin-contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";

contract AddressDriverTest is Test {
    DripsHub internal dripsHub;
    Caller internal caller;
    GitDriver internal driver;
    IERC20 internal erc20;

    address internal admin = address(1);

    function setUp() public {
        DripsHub hubLogic = new DripsHub(10);
        dripsHub = DripsHub(address(new ManagedProxy(hubLogic, address(this))));

        caller = new Caller();

        // Make AddressDriver's driver ID non-0 to test if it's respected by AddressDriver
        dripsHub.registerDriver(address(1));
        dripsHub.registerDriver(address(1));
        uint32 driverId = dripsHub.registerDriver(address(this));
        address oracle = address(this);
        GitDriver driverLogic = new GitDriver(dripsHub, address(caller), driverId, oracle);
        driver = GitDriver(address(new ManagedProxy(driverLogic, admin)));
        dripsHub.updateDriverAddress(driverId, address(driver));
    }

    function testBasicVerify() public {
        string memory gitRepo = "github.com/radicle-dev/drips-contracts";
        address owner = address(0xA);
        uint projectId = driver.calcProjectId(gitRepo);
        assertEq(driver.oracle(), address(this), "oracle not set correctly");
        driver.verifyProjectId(gitRepo, owner);
        assertEq(driver.projectOwner(projectId), owner);  
    }
}
