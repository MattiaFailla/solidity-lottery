from scripts.helper import get_account, get_contract
from brownie import Lottery


def deploy_lottery():
    account = get_account(account_id="learning")
    lottery_contract = Lottery(
        get_contract("eth_usd_price_feed").address

    )
    pass


def main():
    deploy_lottery()
