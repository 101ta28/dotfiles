import {
  BaseConfig,
  ContextBuilder,
  Dpp,
  Plugin,
} from "https://deno.land/x/dpp_vim@v1.0.0/types.ts";
import { Denops, fn } from "https://deno.land/x/dpp_vim@v1.0.0/deps.ts";

export class Config extends BaseConfig {
  override async config(args: {
    denops: Denops;
    contextBuilder: ContextBuilder;
    basePath: string;
    dpp: Dpp;
  }): Promise<{
    plugins: Plugin[];
    stateLines: string[];
  }> {
    args.contextBuilder.setGlobal({
      protocols: ["git"],
    });

    type Toml = {
      hooks_file?: string;
      ftplugins?: Record<string, string>;
      plugins?: Plugin[];
    };

    type LazyMakeStateResult = {
      plugins: Plugin[];
      stateLines: string[];
    };

    const [context, options] = await args.contextBuilder.get(args.denops);
    const dotfilesDir = "~/.config/nvim/";

    const tomls: Toml[] = [];
    const plugins: Plugin[] = [];

    // プラグインリストを直接定義
    plugins.push({
      repo: "Shougo/dpp.vim",
      name: "dpp.vim",
    });
    
    plugins.push({
      repo: "denops/denops.vim",
      name: "denops.vim",
    });

    plugins.push({
      repo: "itchyny/lightline.vim",
      name: "lightline.vim",
    });

    plugins.push({
      repo: "cohama/lexima.vim",
      name: "lexima.vim",
    });

    return {
      plugins: plugins,
      stateLines: [],
    };
  }
}