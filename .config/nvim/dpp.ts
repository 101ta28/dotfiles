import {
  BaseConfig,
  type ConfigReturn,
} from "jsr:@shougo/dpp-vim@~3.1.0/config";
import type {
  ContextBuilder,
  Plugin,
} from "jsr:@shougo/dpp-vim@~3.1.0/types";
import type { Denops } from "jsr:@denops/std@~7.3.0";
import * as fn from "jsr:@denops/std@~7.3.0/function";

export class Config extends BaseConfig {
  override async config(args: {
    denops: Denops;
    contextBuilder: ContextBuilder;
    basePath: string;
  }): Promise<ConfigReturn> {
    args.contextBuilder.setGlobal({
      protocols: ["git"],
    });

    const plugins: Plugin[] = [
      { name: "dpp.vim", repo: "Shougo/dpp.vim" },
      { name: "denops.vim", repo: "vim-denops/denops.vim" },
      {
        name: "dpp-ext-installer",
        repo: "Shougo/dpp-ext-installer",
      },
      { name: "dpp-protocol-git", repo: "Shougo/dpp-protocol-git" },
      { name: "lightline.vim", repo: "itchyny/lightline.vim" },
      { name: "lexima.vim", repo: "cohama/lexima.vim" },
    ];

    return {
      checkFiles: [
        await fn.expand(args.denops, "~/.config/nvim/dpp.ts") as string,
      ],
      plugins,
      stateLines: [],
    };
  }
}
