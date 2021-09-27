from scripts.helper import get_account, get_contract
from brownie import Lottery, config, network


def deploy_lottery():
    account = get_account(account_id="learning")
    lottery_contract = Lottery.deploy(
        get_contract("eth_usd_price_feed").address,
        get_contract("vfr_coordinator").address,
        get_contract("link_token").address,
        config["networks"][network.show_active()]["fee"],
        config["networks"][network.show_active()]["keyhash"],
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify", False),
    )
    print("Lottery contract deployed!")
    return lottery_contract


def start_lottery():
    print("Starting lottery...")
    account = get_account(account_id="learning")
    lottery = Lottery[-1]
    start_tx = lottery.startLottery({"from": account})
    start_tx.wait(1)
    print("Lottery is started.")


def enter_lottery():
    account = get_account()
    lottery = Lottery[-1]
    value = lottery.getEntranceFee() + 10000000
    tx = lottery.enter({"from": account, "value": value})
    tx.wait(1)
    print("Entered the lottery!")


def end_lottery():
    """
    The contract will revert if no Link token are available in the contract.balance
    """
    account = get_account(account_id="learning")
    lottery = Lottery[-1]
    tx = lottery.endLottery({"from": account})
    tx.wait(1)
    print("Lottery ended!")


def main():
    deploy_lottery()
    start_lottery()
    enter_lottery()
